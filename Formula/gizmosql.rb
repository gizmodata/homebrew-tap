# typed: false
# frozen_string_literal: true

class Gizmosql < Formula
  desc "High-performance SQL server built on DuckDB/SQLite with Arrow Flight SQL"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.14.2"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.14.2/gizmosql_cli_macos_arm64.zip"
      sha256 "c8025e2a3fe3960c4ed277857aa141cabf8afb30df18037621a7b3921081649f"
    end
    on_intel do
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.14.2/gizmosql_cli_macos_amd64.zip"
      sha256 "b61d3bfbbd925a70b5a547f310692ed92f917eec21dbdf0a3b72a89cc6e13e72"
    end
  end

  def install
    bin.install "gizmosql_server"
    bin.install "gizmosql_client"
  end

  def caveats
    <<~EOS
      GizmoSQL server can be started with:
        gizmosql_server --database-filename /path/to/database.duckdb

      GizmoSQL client can connect with:
        gizmosql_client --host localhost --port 31337 --command Execute --query "SELECT 1"

      For TLS and authentication options, see:
        gizmosql_server --help
        gizmosql_client --help
    EOS
  end

  test do
    assert_match "gizmosql_server", shell_output("#{bin}/gizmosql_server --help 2>&1", 1)
  end
end
