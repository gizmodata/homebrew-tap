#!/usr/bin/env bash
# Puts an up-to-date Homebrew on PATH for the steps that follow (GitHub Actions).
#
# macOS runners have brew on PATH. The Linux x86-64 images ship it in /home/linuxbrew without
# putting it on PATH, and an image without it gets Homebrew's own installer. Either way the
# runner image's copy can be months old, so it is updated before anything is installed.
set -euo pipefail

if ! command -v brew > /dev/null; then
  prefix=""
  for candidate in /home/linuxbrew/.linuxbrew /opt/homebrew /usr/local; do
    if [ -x "$candidate/bin/brew" ]; then prefix="$candidate"; break; fi
  done
  if [ -z "$prefix" ]; then
    installer="$(mktemp)"
    curl --fail --silent --show-error --location --retry 3 \
      --output "$installer" https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
    NONINTERACTIVE=1 /bin/bash "$installer"
    for candidate in /home/linuxbrew/.linuxbrew /opt/homebrew /usr/local; do
      if [ -x "$candidate/bin/brew" ]; then prefix="$candidate"; break; fi
    done
  fi
  [ -n "$prefix" ] || { echo "Homebrew is not installed and its installer left no brew" >&2; exit 1; }
  export PATH="$prefix/bin:$prefix/sbin:$PATH"
  if [ -n "${GITHUB_PATH:-}" ]; then
    { echo "$prefix/bin"; echo "$prefix/sbin"; } >> "$GITHUB_PATH"
  fi
fi

export HOMEBREW_NO_ANALYTICS=1 HOMEBREW_NO_ENV_HINTS=1
brew update
brew --version
