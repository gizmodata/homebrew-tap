#!/usr/bin/env bash
# Installs and tests formulae and casks from a checkout of this tap, the way a user gets them:
# `brew install`, `brew test`, then `brew uninstall`.
#
#   scripts/ci-test.sh [--tap NAME] [--tap-dir DIR] [--keep] <formula>... cask:<cask>...
#
#   --tap NAME     the tap name to install under (default gizmodata/tap). For a run on your own
#                  machine, give a throwaway name (say tap-test/tap) so your real tap is untouched.
#   --tap-dir DIR  the checkout to test (default: this script's repository). It is linked into
#                  Homebrew's Taps directory under NAME; a tap already there under that name is
#                  never replaced, only a link this script made before.
#   --keep         leave what was installed in place
#
# A formula is installed, tested (its `test do` block) and uninstalled. A cask is installed,
# every app it installs must pass `codesign --verify` and Gatekeeper (`spctl`), and it is
# uninstalled. Casks are macOS only: on Linux they are reported as skipped. Because uninstalling
# a cask quits the app and removes it from /Applications, casks are only installed where CI=true
# (GitHub Actions) or with HOMEBREW_TAP_TEST_CASKS=1.
#
# Exits non-zero when anything fails, and when nothing at all was tested.
set -euo pipefail

TAP="gizmodata/tap"
TAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEEP=0
TARGETS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --tap) TAP="${2:?--tap needs a name}"; shift 2 ;;
    --tap-dir) TAP_DIR="$(cd "${2:?--tap-dir needs a directory}" && pwd)"; shift 2 ;;
    --keep) KEEP=1; shift ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *) TARGETS+=("$1"); shift ;;
  esac
done
if [ ${#TARGETS[@]} -eq 0 ]; then
  echo "usage: ci-test.sh [--tap NAME] [--tap-dir DIR] [--keep] <formula>... cask:<cask>..." >&2
  exit 2
fi
command -v brew > /dev/null || { echo "brew is not on PATH" >&2; exit 1; }
[[ "$TAP" =~ ^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$ ]] || { echo "not a tap name: $TAP" >&2; exit 2; }

export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_NO_ENV_HINTS=1 HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1

# ---- make the checkout the tap -----------------------------------------------------------
taps="$(brew --repository)/Library/Taps"
link="$taps/${TAP%%/*}/homebrew-${TAP##*/}"
if [ -L "$link" ]; then
  rm "$link"
elif [ -e "$link" ]; then
  if [ "$(cd "$link" && pwd -P)" != "$(cd "$TAP_DIR" && pwd -P)" ]; then
    echo "$TAP is already tapped at $link; not replacing it. Pass --tap <another name>." >&2
    exit 1
  fi
fi
if [ ! -e "$link" ]; then
  mkdir -p "$(dirname "$link")"
  ln -s "$TAP_DIR" "$link"
fi
echo "==> testing $TAP from $TAP_DIR ($(brew --version | head -1), $(uname -sm))"
# Homebrew 6+ loads a third-party tap only once it is trusted.
if brew trust --help > /dev/null 2>&1; then
  brew trust "$TAP"
fi

# ---- the targets -------------------------------------------------------------------------
tested=0
skipped=0

test_formula() {
  local full="$TAP/$1"
  echo "==> formula $full"
  brew install --formula "$full"
  brew test "$full"
  if [ "$KEEP" -eq 0 ]; then
    brew uninstall --formula "$full"
  fi
  tested=$((tested + 1))
}

test_cask() {
  local full="$TAP/$1" apps app
  if [ "$(uname -s)" != Darwin ]; then
    echo "==> cask $full: skipped (casks are macOS only)"
    skipped=$((skipped + 1))
    return 0
  fi
  if [ "${CI:-}" != true ] && [ "${HOMEBREW_TAP_TEST_CASKS:-}" != 1 ]; then
    echo "cask $full: not installing a cask outside CI (it replaces and removes apps in /Applications);" >&2
    echo "set HOMEBREW_TAP_TEST_CASKS=1 to do it anyway." >&2
    return 1
  fi
  echo "==> cask $full"
  brew install --cask "$full"
  # The apps the cask says it installs, as paths in /Applications.
  apps="$(brew info --cask --json=v2 "$full" | python3 -c '
import json, sys
cask = json.load(sys.stdin)["casks"][0]
for artifact in cask["artifacts"]:
    for app in artifact.get("app", []):
        if isinstance(app, str):
            print("/Applications/" + app.rsplit("/", 1)[-1])
')"
  [ -n "$apps" ] || { echo "cask $full installs no app this script can check" >&2; return 1; }
  while IFS= read -r app; do
    [ -d "$app" ] || { echo "$app is missing after the install" >&2; return 1; }
    codesign --verify --deep --strict "$app"
    spctl --assess --type execute --verbose "$app"
    echo "$app: signed, and accepted by Gatekeeper"
  done <<< "$apps"
  if [ "$KEEP" -eq 0 ]; then
    brew uninstall --cask "$full"
  fi
  tested=$((tested + 1))
}

for target in "${TARGETS[@]}"; do
  case "$target" in
    cask:*) test_cask "${target#cask:}" ;;
    *) test_formula "$target" ;;
  esac
done

echo "==> tested $tested, skipped $skipped"
if [ "$tested" -eq 0 ]; then
  echo "nothing was tested" >&2
  exit 1
fi
