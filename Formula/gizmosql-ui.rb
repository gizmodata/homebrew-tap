class GizmosqlUi < Formula
  desc "Web-based SQL interface for GizmoSQL servers"
  homepage "https://github.com/gizmodata/gizmosql-ui"
  version "2.2.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-macos-arm64"
      sha256 "73dce37f71cc92a84a34bfe252adb50517effa7cf21b8c85b84867c264030d58"

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
