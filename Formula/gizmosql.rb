# typed: false
# frozen_string_literal: true

class Gizmosql < Formula
  desc "High-performance SQL server built on DuckDB/SQLite with Arrow Flight SQL"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.22.4"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.22.4/gizmosql_cli_macos_arm64.zip"
      sha256 "992c5277831f4a586b1df7f44ae24397dbfc6f97f414156af717bc62d180c683"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.22.4/gizmosql_cli_linux_arm64.zip"
      sha256 "e51f48c5e6b35f748d3e905c245bd9588d822cc2d05bea55def5070f977c94a8"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.22.4/gizmosql_cli_linux_amd64.zip"
      sha256 "c09297292b99f1661c4c2328996327cbd8df1dbda868699d7df15eed71772e03"
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
