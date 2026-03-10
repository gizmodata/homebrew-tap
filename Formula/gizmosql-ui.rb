class GizmosqlUi < Formula
  desc "Web-based SQL interface for GizmoSQL servers"
  homepage "https://github.com/gizmodata/gizmosql-ui"
  version "2.5.1"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-macos-arm64"
      sha256 "38cfa09abe404f7430d60a618580558a7e6a02ebb0835990592c090044813549"

      def install
        bin.install "gizmosql-ui-macos-arm64" => "gizmosql-ui"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-linux-arm64"
      sha256 "2ac5d2e6616c609d73d025f664168084fb6e29c1d93360696b78262aeccd843e"

      def install
        bin.install "gizmosql-ui-linux-arm64" => "gizmosql-ui"
      end
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-linux-x64"
      sha256 "f51d6e968fd48180a7334b097c0d6699a2ca7460a2c671741088994f8d55e703"

      def install
        bin.install "gizmosql-ui-linux-x64" => "gizmosql-ui"
      end
    end
  end

  def caveats
    <<~EOS
      GizmoSQL UI starts a local web server and opens your browser.

      To start GizmoSQL UI:
        gizmosql-ui

      The server runs at http://localhost:3000 by default.
      Set PORT environment variable to use a different port.
    EOS
  end

  test do
    assert_match "GizmoSQL", shell_output("#{bin}/gizmosql-ui --help 2>&1", 1)
  end
end
