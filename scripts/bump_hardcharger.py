#!/usr/bin/env python3
"""Point the hardcharger formula and the hardcharger-desktop cask at a Hardcharger release.

    scripts/bump_hardcharger.py --version 2.10.0 [--sha256sums FILE] [--tap-root DIR]
                                [--allow-downgrade]

It rewrites only the version, the release URLs and the checksums, taken from the release's
SHA256SUMS (downloaded from GitHub unless --sha256sums names a copy). Everything else in the
two files is maintained by hand.

Exit status: 0 when the files now describe that version (changed or already there), or when
the version is older than the one in the tap (nothing is changed: a patch to an older release
line never moves Homebrew backwards); non-zero, with nothing written, on anything it cannot
do exactly: a version that isn't X.Y.Z, a SHA256SUMS without one of the assets, a file whose
shape it doesn't recognise.

With GITHUB_OUTPUT set it also writes `changed=true|false` and `version=<the tap's version>`.
"""

from __future__ import annotations

import argparse
import os
import re
import sys
import urllib.request
from pathlib import Path

REPOSITORY = "gizmodata/hardcharger"
FORMULA = Path("Formula/hardcharger.rb")
CASK = Path("Casks/hardcharger-desktop.rb")
FORMULA_ASSETS = (
    "hardcharger-macos-arm64.tar.gz",
    "hardcharger-linux-amd64.tar.gz",
    "hardcharger-linux-arm64.tar.gz",
)
CASK_ASSET = "Hardcharger-desktop-macos-arm64.dmg"

VERSION = re.compile(r"(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)")
SHA256 = re.compile(r"[0-9a-f]{64}")
VERSION_LINE = re.compile(r'^(?P<indent>\s*)version "(?P<version>[^"]*)"$', flags=re.MULTILINE)
SHA256_LINE = re.compile(r'^(?P<indent>\s*)sha256 "(?P<sha256>[^"]*)"$', flags=re.MULTILINE)


class BumpError(Exception):
    """Something this script cannot do exactly; nothing has been written."""


def parse_version(*, text: str) -> tuple[int, int, int]:
    match = VERSION.fullmatch(text)
    if match is None:
        raise BumpError(f"'{text}' is not a release version (X.Y.Z; release candidates never reach Homebrew)")
    return (int(match.group(1)), int(match.group(2)), int(match.group(3)))


def parse_sha256sums(*, text: str) -> dict[str, str]:
    """`sha256sum` output: one "<64 hex>  <name>" line per asset."""
    sums: dict[str, str] = {}
    for line in text.splitlines():
        if not line.strip():
            continue
        parts = line.split()
        if len(parts) != 2 or SHA256.fullmatch(parts[0]) is None:
            raise BumpError(f"SHA256SUMS has a line that is not '<sha256>  <file>': {line!r}")
        sums[parts[1].lstrip("*")] = parts[0]
    if not sums:
        raise BumpError("SHA256SUMS is empty")
    return sums


def checksum(*, sums: dict[str, str], asset: str) -> str:
    if asset not in sums:
        raise BumpError(f"SHA256SUMS has no line for {asset}")
    return sums[asset]


def current_version(*, text: str, path: Path) -> str:
    matches = VERSION_LINE.findall(text)
    if len(matches) != 1:
        raise BumpError(f"{path}: expected exactly one `version \"...\"` line, found {len(matches)}")
    return matches[0][1]


def set_version(*, text: str, version: str, path: Path) -> str:
    current_version(text=text, path=path)
    return VERSION_LINE.sub(lambda match: f'{match.group("indent")}version "{version}"', text)


def formula_version(*, text: str, path: Path = FORMULA) -> str:
    """The formula's `version` line, which its three release URLs must agree with."""
    versions = re.findall(
        r'^\s*url "https://github\.com/' + re.escape(REPOSITORY) + r'/releases/download/v([^/"]+)/[^/"]+"$',
        text,
        flags=re.MULTILINE,
    )
    if len(versions) != len(FORMULA_ASSETS) or len(set(versions)) != 1:
        raise BumpError(f"{path}: expected {len(FORMULA_ASSETS)} release URLs of one version, found {versions}")
    version = current_version(text=text, path=path)
    if versions[0] != version:
        raise BumpError(f"{path}: `version` is {version} but the release URLs are for {versions[0]}")
    return version


def bump_formula(*, text: str, version: str, sums: dict[str, str], path: Path = FORMULA) -> str:
    """Each asset's `url` line gets the new tag, and the `sha256` line under it its checksum."""
    formula_version(text=text, path=path)
    text = set_version(text=text, version=version, path=path)
    for asset in FORMULA_ASSETS:
        pair = re.compile(
            r'^(?P<indent>\s*)url "https://github\.com/'
            + re.escape(REPOSITORY)
            + r'/releases/download/v[^/"]+/'
            + re.escape(asset)
            + r'"\n(?P=indent)sha256 "[^"]*"$',
            flags=re.MULTILINE,
        )
        if len(pair.findall(text)) != 1:
            raise BumpError(f"{path}: expected exactly one url + sha256 pair for {asset}")
        digest = checksum(sums=sums, asset=asset)
        text = pair.sub(
            lambda match, asset=asset, digest=digest: (
                f'{match.group("indent")}url "https://github.com/{REPOSITORY}/releases/download/v{version}/{asset}"\n'
                f'{match.group("indent")}sha256 "{digest}"'
            ),
            text,
        )
    return text


def bump_cask(*, text: str, version: str, sums: dict[str, str], path: Path = CASK) -> str:
    """The cask's URL is built from `version`, so only the version and the one checksum change."""
    expected_url = f'url "https://github.com/{REPOSITORY}/releases/download/v#{{version}}/{CASK_ASSET}"'
    if text.count(expected_url) != 1:
        raise BumpError(f"{path}: expected the line {expected_url}")
    if len(SHA256_LINE.findall(text)) != 1:
        raise BumpError(f"{path}: expected exactly one `sha256 \"...\"` line")
    text = set_version(text=text, version=version, path=path)
    digest = checksum(sums=sums, asset=CASK_ASSET)
    return SHA256_LINE.sub(lambda match: f'{match.group("indent")}sha256 "{digest}"', text)


def download_sha256sums(*, version: str) -> str:
    url = f"https://github.com/{REPOSITORY}/releases/download/v{version}/SHA256SUMS"
    try:
        with urllib.request.urlopen(url=url, timeout=60) as response:
            return response.read().decode(encoding="utf-8")
    except OSError as error:
        raise BumpError(f"could not download {url}: {error}") from error


def bump(*, tap_root: Path, version: str, sha256sums: str, allow_downgrade: bool = False) -> dict[str, str]:
    """Rewrites both files (or neither). Returns {"changed": "true"|"false", "version": <tap's>}."""
    target = parse_version(text=version)
    sums = parse_sha256sums(text=sha256sums)

    before = {path: (tap_root / path).read_text(encoding="utf-8") for path in (FORMULA, CASK)}
    existing_versions = {
        FORMULA: formula_version(text=before[FORMULA]),
        CASK: current_version(text=before[CASK], path=CASK),
    }
    for path, existing in existing_versions.items():
        if parse_version(text=existing) > target and not allow_downgrade:
            print(f"{path} is at {existing}, newer than {version}: leaving the tap as it is")
            return {"changed": "false", "version": existing}

    after = {
        FORMULA: bump_formula(text=before[FORMULA], version=version, sums=sums),
        CASK: bump_cask(text=before[CASK], version=version, sums=sums),
    }
    changed = after != before
    for path, text in after.items():
        if text != before[path]:
            (tap_root / path).write_text(text, encoding="utf-8")
            print(f"{path}: {existing_versions[path]} -> {version}")
        else:
            print(f"{path}: already {version}")
    return {"changed": "true" if changed else "false", "version": version}


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--version", required=True, help="the release, X.Y.Z or vX.Y.Z")
    parser.add_argument("--sha256sums", type=Path, help="the release's SHA256SUMS (default: download it)")
    parser.add_argument("--tap-root", type=Path, default=Path(__file__).resolve().parent.parent)
    parser.add_argument("--allow-downgrade", action="store_true", help="also move to an older version")
    arguments = parser.parse_args(args=argv)

    version = arguments.version.removeprefix("v")
    try:
        parse_version(text=version)
        if arguments.sha256sums is not None:
            sha256sums = arguments.sha256sums.read_text(encoding="utf-8")
        else:
            sha256sums = download_sha256sums(version=version)
        result = bump(
            tap_root=arguments.tap_root,
            version=version,
            sha256sums=sha256sums,
            allow_downgrade=arguments.allow_downgrade,
        )
    except (BumpError, OSError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    output = os.environ.get("GITHUB_OUTPUT")
    if output:
        with open(file=output, mode="a", encoding="utf-8") as handle:
            for key, value in result.items():
                handle.write(f"{key}={value}\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
