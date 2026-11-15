# The version and checksum below are rewritten by scripts/bump_hardcharger.py after each
# Hardcharger release; everything else is maintained here.
cask "hardcharger-desktop" do
  version "2.13.0"
  sha256 "8f4cb2390cde32f3dad9fbf0f27cf30adc5d98f01f9db83a0bd6c14f25d8955e"

  url "https://github.com/gizmodata/hardcharger/releases/download/v#{version}/Hardcharger-desktop-macos-arm64.dmg"
  name "Hardcharger"
  desc "Desktop app that runs a local Hardcharger DuckDB server and its SQL workspace"
  homepage "https://github.com/gizmodata/hardcharger"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "Hardcharger.app"

  uninstall quit: "com.gizmodata.hardcharger.desktop"

  # Not ~/Library/Application Support/com.gizmodata.hardcharger.desktop: it holds the
  # user's database (Hardcharger.duckdb), which a package manager must never remove.
  zap trash: [
    "~/Library/Caches/com.gizmodata.hardcharger.desktop",
    "~/Library/Preferences/com.gizmodata.hardcharger.desktop.plist",
    "~/Library/Saved Application State/com.gizmodata.hardcharger.desktop.savedState",
    "~/Library/WebKit/com.gizmodata.hardcharger.desktop",
  ]
end
