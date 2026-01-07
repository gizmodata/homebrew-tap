# typed: false
# frozen_string_literal: true

class Gizmosql < Formula
  desc "High-performance SQL server built on DuckDB/SQLite with Arrow Flight SQL"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.14.1"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.14.1/gizmosql_cli_macos_arm64.zip"
      sha256 "a8e6ad30c61c79bdf13f78b3c6f755f2fd39127735a949470089377c06d3b4fa"
    end
    on_intel do
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.14.1/gizmosql_cli_macos_amd64.zip"
      sha256 "b5082cf915f90768c45ac5002f8e1ebf465f1079f6821fbdd7838cdd34988e82"
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
