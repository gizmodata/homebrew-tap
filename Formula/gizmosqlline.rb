class Gizmosqlline < Formula
  desc "GizmoSQL JDBC command-line client for GizmoSQL servers"
  homepage "https://github.com/gizmodata/gizmosqlline"
  version "2.5.0"
  license "Apache-2.0"

  url "https://github.com/gizmodata/gizmosqlline/releases/download/v#{version}/gizmosqlline.jar"
  sha256 "31f5234b02c335845cbf11a5ac8e4d15f0c6073089ec379bb7d35d603c4af686"

  depends_on "openjdk"

  def install
    libexec.install "gizmosqlline.jar"

    (bin/"gizmosqlline").write <<~EOS
      #!/bin/bash
      export JAVA_HOME="#{Formula["openjdk"].opt_prefix}"
      V=$("${JAVA_HOME}/bin/java" -version 2>&1 | head -1 | sed 's/.*"\\([0-9][0-9]*\\).*/\\1/')
      NA=""
      [ "$V" -ge 16 ] 2>/dev/null && NA="--enable-native-access=ALL-UNNAMED"
      [ "$V" -ge 25 ] 2>/dev/null && NA="$NA --sun-misc-unsafe-memory-access=allow"
      exec "${JAVA_HOME}/bin/java" --add-opens=java.base/java.nio=ALL-UNNAMED $NA -jar "#{libexec}/gizmosqlline.jar" "$@"
    EOS
  end

  def caveats
    <<~EOS
      GizmoSQLLine is a GizmoSQL JDBC command-line client.

      To start in interactive mode:
        gizmosqlline

      To connect directly:
        gizmosqlline -u "jdbc:gizmosql://localhost:31337" -n user -p password

      For help with SQLLine commands, type !help after connecting.
    EOS
  end

  test do
    output = shell_output("#{bin}/gizmosqlline --help 2>&1", 0)
    assert_match "GizmoSQLLine", output
  end
end
