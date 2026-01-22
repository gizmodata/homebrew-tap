# typed: false
# frozen_string_literal: true

class Gizmosql < Formula
  desc "High-performance SQL server built on DuckDB/SQLite with Arrow Flight SQL"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.15.0"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on :macos

  url "https://github.com/gizmodata/gizmosql/releases/download/v1.15.0/gizmosql_cli_macos_arm64.zip"
  sha256 "51e79641cfb62c4a0841c5c215270f33d7e5b09583f3a9ac424e44c33e8849ad"

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
