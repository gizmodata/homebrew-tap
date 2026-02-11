class GizmosqlUi < Formula
  desc "Web-based SQL interface for GizmoSQL servers"
  homepage "https://github.com/gizmodata/gizmosql-ui"
  version "2.4.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-macos-arm64"
      sha256 "4732e3fc6e6d90efb35619f941ec50cf5589fddc6c0d03e811099b0a68fabcaf"

      def install
        bin.install "gizmosql-ui-macos-arm64" => "gizmosql-ui"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-linux-arm64"
      sha256 "af4e3716f4e425eb31b9d6e08ec1205333ff52632a3b08953bb6e999bda009eb"

      def install
        bin.install "gizmosql-ui-linux-arm64" => "gizmosql-ui"
      end
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-linux-x64"
      sha256 "d997badad7d467c56e8ebf1f0d96e9a955fe4b008a6185e101f240b99801f14e"

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
