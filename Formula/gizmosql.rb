# typed: false
# frozen_string_literal: true

class Gizmosql < Formula
  desc "High-performance SQL server built on DuckDB/SQLite with Arrow Flight SQL"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.19.6"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.19.6/gizmosql_cli_macos_arm64.zip"
      sha256 "6806c4cbaa14f8b25c9a581e924e8583a361153af89edf123113c657e609d292"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.19.6/gizmosql_cli_linux_arm64.zip"
      sha256 "54d880d157d568c6fd512ebe9bd79599b5e93c5dbecd16905ec2fb721ae6703d"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.19.6/gizmosql_cli_linux_amd64.zip"
      sha256 "6189fcaf5df78b784c434132a1662b5fdde035309df822c63f737ed5573ed02a"
    end
  end

  def install
    bin.install "gizmosql_server"
    bin.install "gizmosql_client"
  end

  def caveats
    <<~EOS
      Start a GizmoSQL server:
        GIZMOSQL_PASSWORD=tiger gizmosql_server --database-filename my_database.duckdb --username scott

      Connect with the interactive SQL shell:
        GIZMOSQL_PASSWORD=tiger gizmosql_client --host localhost --username scott

      Run a single query:
        GIZMOSQL_PASSWORD=tiger gizmosql_client --host localhost --username scott --command "SELECT 1"

      For TLS and authentication options, see:
        gizmosql_server --help
        gizmosql_client --help
    EOS
  end

  test do
    assert_match "gizmosql_server", shell_output("#{bin}/gizmosql_server --help 2>&1", 1)
  end
end
