#!/usr/bin/env python3
"""Tests for bump_hardcharger.py, against copies of the real formula and cask.

    python3 -m unittest discover --start-directory scripts --pattern 'test_*.py'
"""

from __future__ import annotations

import contextlib
import io
import os
import shutil
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parent))

import bump_hardcharger as bump_module  # noqa: E402
from bump_hardcharger import CASK, CASK_ASSET, FORMULA, FORMULA_ASSETS, BumpError, bump, main  # noqa: E402

TAP_ROOT = Path(__file__).resolve().parent.parent


def sha256sums(*, seed: str, leave_out: str | None = None) -> str:
    """A SHA256SUMS whose digests name their asset: <seed digit><index>, padded to 64."""
    lines = []
    for index, asset in enumerate((*FORMULA_ASSETS, CASK_ASSET, "hardcharger-windows-amd64.zip")):
        if asset != leave_out:
            lines.append(f"{(seed + str(index)).ljust(64, '0')}  {asset}")
    return "\n".join(lines) + "\n"


def digest(*, seed: str, asset: str) -> str:
    return (seed + str((*FORMULA_ASSETS, CASK_ASSET).index(asset))).ljust(64, "0")


class BumpTest(unittest.TestCase):
    def setUp(self) -> None:
        self.root = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.root)
        for path in (FORMULA, CASK):
            (self.root / path).parent.mkdir(parents=True)
            shutil.copyfile(src=TAP_ROOT / path, dst=self.root / path)
        # A known starting point, whatever version the tap is at today.
        self.run_bump(version="5.0.0", seed="a", allow_downgrade=True)

    def run_bump(self, *, version: str, seed: str, allow_downgrade: bool = False, leave_out: str | None = None):
        with contextlib.redirect_stdout(new_target=io.StringIO()):
            return bump(
                tap_root=self.root,
                version=version,
                sha256sums=sha256sums(seed=seed, leave_out=leave_out),
                allow_downgrade=allow_downgrade,
            )

    def read(self, *, path: Path) -> str:
        return (self.root / path).read_text(encoding="utf-8")

    def test_bump_rewrites_version_urls_and_checksums_only(self) -> None:
        formula_before = self.read(path=FORMULA)
        cask_before = self.read(path=CASK)

        result = self.run_bump(version="5.1.0", seed="b")

        self.assertEqual(result, {"changed": "true", "version": "5.1.0"})
        formula = self.read(path=FORMULA)
        self.assertIn('  version "5.1.0"\n', formula)
        self.assertNotIn("5.0.0", formula)
        for asset in FORMULA_ASSETS:
            # Each asset's own checksum sits directly under its own URL.
            self.assertRegex(
                formula,
                rf'url "https://github\.com/gizmodata/hardcharger/releases/download/v5\.1\.0/{asset}"\n'
                rf'\s+sha256 "{digest(seed="b", asset=asset)}"\n',
            )
        cask = self.read(path=CASK)
        self.assertIn('  version "5.1.0"\n', cask)
        self.assertIn(f'  sha256 "{digest(seed="b", asset=CASK_ASSET)}"\n', cask)

        # Nothing but those lines moved.
        def other_lines(text: str) -> list[str]:
            return [line for line in text.splitlines() if not line.lstrip().startswith(("version ", "url ", "sha256 "))]

        self.assertEqual(other_lines(formula), other_lines(formula_before))
        self.assertEqual(other_lines(cask), other_lines(cask_before))

    def test_same_version_again_changes_nothing(self) -> None:
        self.assertEqual(self.run_bump(version="5.0.0", seed="a"), {"changed": "false", "version": "5.0.0"})

    def test_an_older_version_leaves_the_tap_alone(self) -> None:
        formula_before = self.read(path=FORMULA)
        result = self.run_bump(version="4.9.9", seed="c")
        self.assertEqual(result, {"changed": "false", "version": "5.0.0"})
        self.assertEqual(self.read(path=FORMULA), formula_before)

    def test_versions_compare_as_numbers(self) -> None:
        self.assertEqual(self.run_bump(version="5.0.10", seed="d")["changed"], "true")
        self.assertEqual(self.run_bump(version="5.0.9", seed="e"), {"changed": "false", "version": "5.0.10"})

    def test_a_missing_asset_writes_nothing(self) -> None:
        for asset in (*FORMULA_ASSETS, CASK_ASSET):
            with self.subTest(asset=asset):
                formula_before = self.read(path=FORMULA)
                cask_before = self.read(path=CASK)
                with self.assertRaisesRegex(BumpError, f"no line for {asset}"):
                    self.run_bump(version="6.0.0", seed="f", leave_out=asset)
                self.assertEqual(self.read(path=FORMULA), formula_before)
                self.assertEqual(self.read(path=CASK), cask_before)

    def test_release_candidates_and_malformed_versions_are_refused(self) -> None:
        for version in ("5.1.0-rc.1", "5.1", "latest", "", "5.1.0.post1", "05.1.0"):
            with self.subTest(version=version):
                with self.assertRaisesRegex(BumpError, "not a release version"):
                    self.run_bump(version=version, seed="b")

    def test_an_empty_or_malformed_sha256sums_is_refused(self) -> None:
        for text, message in (("", "empty"), ("\n\n", "empty"), ("<html>Not Found</html>\n", "not '<sha256>")):
            with self.subTest(text=text):
                with self.assertRaisesRegex(BumpError, message):
                    bump(tap_root=self.root, version="5.1.0", sha256sums=text)

    def test_a_formula_it_does_not_recognise_is_refused(self) -> None:
        formula = self.root / FORMULA
        formula.write_text(self.read(path=FORMULA).replace("hardcharger-linux-arm64.tar.gz", "renamed.tar.gz"))
        with self.assertRaisesRegex(BumpError, "exactly one url \\+ sha256 pair for hardcharger-linux-arm64"):
            self.run_bump(version="5.1.0", seed="b")

    def test_formula_urls_of_two_versions_are_refused(self) -> None:
        formula = self.root / FORMULA
        formula.write_text(self.read(path=FORMULA).replace("v5.0.0/hardcharger-linux-arm64", "v4.0.0/hardcharger-linux-arm64"))
        with self.assertRaisesRegex(BumpError, "release URLs of one version"):
            self.run_bump(version="5.1.0", seed="b")

    def test_a_formula_whose_version_and_urls_disagree_is_refused(self) -> None:
        formula = self.root / FORMULA
        formula.write_text(self.read(path=FORMULA).replace('version "5.0.0"', 'version "5.0.1"'))
        with self.assertRaisesRegex(BumpError, "`version` is 5.0.1 but the release URLs are for 5.0.0"):
            self.run_bump(version="5.1.0", seed="b")

    def test_command_line_takes_a_v_prefix_and_writes_github_output(self) -> None:
        sums = self.root / "SHA256SUMS"
        sums.write_text(sha256sums(seed="b"), encoding="utf-8")
        output = self.root / "github-output"
        with mock.patch.dict(os.environ, {"GITHUB_OUTPUT": str(output)}), contextlib.redirect_stdout(io.StringIO()):
            status = main(argv=["--version", "v5.2.0", "--sha256sums", str(sums), "--tap-root", str(self.root)])
        self.assertEqual(status, 0)
        self.assertEqual(output.read_text(encoding="utf-8"), "changed=true\nversion=5.2.0\n")
        self.assertIn('version "5.2.0"', self.read(path=CASK))

    def test_command_line_fails_without_writing_output_on_a_bad_version(self) -> None:
        output = self.root / "github-output"
        with (
            mock.patch.dict(os.environ, {"GITHUB_OUTPUT": str(output)}),
            contextlib.redirect_stderr(io.StringIO()) as stderr,
            mock.patch.object(bump_module, "download_sha256sums") as download,
        ):
            status = main(argv=["--version", "5.2.0-rc.1", "--tap-root", str(self.root)])
        self.assertEqual(status, 1)
        self.assertIn("not a release version", stderr.getvalue())
        self.assertFalse(output.exists())
        download.assert_not_called()


if __name__ == "__main__":
    unittest.main()
