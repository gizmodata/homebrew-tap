class GizmosqlUi < Formula
  desc "Web-based SQL interface for GizmoSQL servers"
  homepage "https://github.com/gizmodata/gizmosql-ui"
  version "2.1.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-macos-arm64"
      sha256 "e35a710cce24cf86d01df8664aa31a98902ce6ef9b12ba1414945a1e8892be8b"

      def install
        bin.install "gizmosql-ui-macos-arm64" => "gizmosql-ui"
      end
    end
  end

  def caveats
    <<~EOS
      GizmoSQL UI starts a local web server and opens your browser.

      To start GizmoSQL UI:
        gizmosql-ui

      The server runs at http://localhost:4821 by default.
      Set PORT environment variable to use a different port.
    EOS
  end

  test do
    assert_match "GizmoSQL", shell_output("#{bin}/gizmosql-ui --help 2>&1", 1)
  end
end
