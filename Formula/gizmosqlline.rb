class Gizmosqlline < Formula
  desc "GizmoSQL JDBC command-line client for GizmoSQL servers"
  homepage "https://github.com/gizmodata/gizmosqlline"
  version "2.4.1"
  license "Apache-2.0"

  url "https://github.com/gizmodata/gizmosqlline/releases/download/v#{version}/gizmosqlline.jar"
  sha256 "57f154913b50e3264d11dc582ce1ffe76aeeca9ead4309a198756876977aad34"

  depends_on "openjdk"

  def install
    libexec.install "gizmosqlline.jar"

    (bin/"gizmosqlline").write <<~EOS
      #!/bin/bash
      export JAVA_HOME="#{Formula["openjdk"].opt_prefix}"
      exec "${JAVA_HOME}/bin/java" --add-opens=java.base/java.nio=ALL-UNNAMED --enable-native-access=ALL-UNNAMED -jar "#{libexec}/gizmosqlline.jar" "$@"
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
