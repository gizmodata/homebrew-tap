# typed: false
# frozen_string_literal: true

class Gizmosql < Formula
  desc "High-performance SQL server built on DuckDB/SQLite with Arrow Flight SQL"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.25.1"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.25.1/gizmosql_cli_macos_arm64.zip"
      sha256 "abe88291a25f04823bf754951441a0a11e40a2ed7b8573192ee35c5d5442cd7e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.25.1/gizmosql_cli_linux_arm64.zip"
      sha256 "a5f0d5b822e05055690b4244f03cc9bc547fd133a5cf3031e9662521ff145385"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.25.1/gizmosql_cli_linux_amd64.zip"
      sha256 "74b8948533fe459bc741c21e74972acd58aac897ae75316d9110fe90a2ad964b"
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
