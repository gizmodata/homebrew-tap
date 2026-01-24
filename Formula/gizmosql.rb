# typed: false
# frozen_string_literal: true

class Gizmosql < Formula
  desc "High-performance SQL server built on DuckDB/SQLite with Arrow Flight SQL"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.15.1"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v#{version}/gizmosql_cli_macos_arm64.zip"
      sha256 "b31a7f37e6439f7818856b1b65c5cfe99765ad7d91a28a1bb330a4a072e750df"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v#{version}/gizmosql_cli_linux_arm64.zip"
      sha256 "cf8b2c99b2029d64aa668a876840c1d95b2d894dabc2cfb7923314b7c1b0c1f8"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v#{version}/gizmosql_cli_linux_amd64.zip"
      sha256 "3a48527c964ae0be8b8be50e17b7a2a411c28cf9c130b899319db4899ffaaefa"
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
