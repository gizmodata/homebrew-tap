# typed: false
# frozen_string_literal: true

class Gizmosql < Formula
  desc "High-performance SQL server built on DuckDB/SQLite with Arrow Flight SQL"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.17.3"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.17.3/gizmosql_cli_macos_arm64.zip"
      sha256 "b8223b0ecbdd8cd907e993e01bacbdbc00e0ccae34aae4b0349390553d11cfd3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.17.3/gizmosql_cli_linux_arm64.zip"
      sha256 "ca155b3c6655f4d570627ae18fdaee4f20197d1887d2acf309dcff632d33500d"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.17.3/gizmosql_cli_linux_amd64.zip"
      sha256 "3f854de8b706968e62fec88ef3d2ac6acf2ae944ba9bcc653ff64c8e0885fdb5"
    end
  end

  def install
    bin.install "gizmosql_server"
    bin.install "gizmosql_client"
  end

  def caveats
    <<~EOS
      GizmoSQL server can be started with:
        GIZMOSQL_PASSWORD=tiger gizmosql_server --database-filename /path/to/database.duckdb --username scott

      GizmoSQL client can connect with:
        gizmosql_client --host localhost --port 31337 --username scott --password tiger --command Execute --query "SELECT 1"

      For TLS and authentication options, see:
        gizmosql_server --help
        gizmosql_client --help
    EOS
  end

  test do
    assert_match "gizmosql_server", shell_output("#{bin}/gizmosql_server --help 2>&1", 1)
  end
end
