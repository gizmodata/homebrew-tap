class GizmosqlUi < Formula
  desc "Web-based SQL interface for GizmoSQL servers"
  homepage "https://github.com/gizmodata/gizmosql-ui"
  version "2.7.3"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-macos-arm64"
      sha256 "8d29096eda917d99fe577a4fa4d0eaba0b0d6ab9d93d7cabd2cea279616ae61e"

      def install
        bin.install "gizmosql-ui-macos-arm64" => "gizmosql-ui"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-linux-arm64"
      sha256 "6aa646e850acb70f5d375dcbb436c616451b36491b8858706fd9a67827c26043"

      def install
        bin.install "gizmosql-ui-linux-arm64" => "gizmosql-ui"
      end
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-linux-x64"
      sha256 "669522d3f864fd73465b22a7e689d24a452fe8b2b00d3a01424ab64f8234c60a"

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
