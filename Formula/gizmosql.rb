# typed: false
# frozen_string_literal: true

class Gizmosql < Formula
  desc "High-performance SQL server built on DuckDB/SQLite with Arrow Flight SQL"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.38.1"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.38.1/gizmosql_cli_macos_arm64.zip"
      sha256 "6e580ad45d84b2ddd2dde537a41fb3b47334c57223b2fdfb7bb588926461ce94"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.38.1/gizmosql_cli_linux_arm64.zip"
      sha256 "215926e1b45fc83fa507664742c00a5e4826d9d85d2689f7be9ac561b5ee68fa"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.38.1/gizmosql_cli_linux_amd64.zip"
      sha256 "d41a8bc94f1cf3cfb765c31b2e6fbf10fa6cfe7c2bc1719d862ee9cb6e5d2000"
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
