class GizmosqlUi < Formula
  desc "Web-based SQL interface for GizmoSQL servers"
  homepage "https://github.com/gizmodata/gizmosql-ui"
  version "2.7.1"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-macos-arm64"
      sha256 "7b0f51f8d5bc0bb421c9181d68d9591f0a7ed535f6313a92e101d036c293a78c"

      def install
        bin.install "gizmosql-ui-macos-arm64" => "gizmosql-ui"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-linux-arm64"
      sha256 "3b0a754ac3d0861ffcb8a459e4d3d2402b5739695077d5cb0a7c0371940fdca4"

      def install
        bin.install "gizmosql-ui-linux-arm64" => "gizmosql-ui"
      end
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql-ui/releases/download/v#{version}/gizmosql-ui-linux-x64"
      sha256 "51c82162cf243aa32b406748486bbe9400fc122ff29c3f4368e4858a14fa2a2f"

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
