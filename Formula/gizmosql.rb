# typed: false
# frozen_string_literal: true

class Gizmosql < Formula
  desc "High-performance SQL server built on DuckDB/SQLite with Arrow Flight SQL"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.30.1"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.30.1/gizmosql_cli_macos_arm64.zip"
      sha256 "5e3e79d9bd21179a07cf771351fbefb0ddcfc6558edcb09d13b9765d01906097"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.30.1/gizmosql_cli_linux_arm64.zip"
      sha256 "4fd3115fa7e36253e192c71cff50c24ab25372085165725b93017e3ed47c2d75"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.30.1/gizmosql_cli_linux_amd64.zip"
      sha256 "4684400ba2e69d0c836f9fa4c8eb0503e15bb7f74ae5f0323735ba66b6d0cbd9"
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
