class GizmosqlUi < Formula
  desc "Web-based SQL interface for GizmoSQL servers"
  homepage "https://github.com/gizmodata/gizmosql-ui"
  version "2.2.1"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-macos-arm64"
      sha256 "27a241bfe3a0a1c2ee79a8394637d3059420c73d660caba7b72b874513c88457"

      def install
        bin.install "gizmosql-ui-macos-arm64" => "gizmosql-ui"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-linux-arm64"
      sha256 "2bd2b2bd8e93595cab83167437b10a97bcb22c06efcd0e3a47391d23edbe6d7e"

      def install
        bin.install "gizmosql-ui-linux-arm64" => "gizmosql-ui"
      end
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-linux-x64"
      sha256 "caa50e0666f6411f84a6cda917fe205603ad306711a34848b969ac3d56abfb30"

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
