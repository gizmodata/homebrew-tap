# typed: false
# frozen_string_literal: true

class Gizmosql < Formula
  desc "High-performance SQL server built on DuckDB/SQLite with Arrow Flight SQL"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.17.2"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.17.2/gizmosql_cli_macos_arm64.zip"
      sha256 "19d171c7bbf766621efd77d149f7fbf48069766d125ade93a35e1537653caf79"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.17.2/gizmosql_cli_linux_arm64.zip"
      sha256 "7bfe8e9c6bec6a7da22cb28c460a91895dc898a375148467ac6be33387d17c41"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.17.2/gizmosql_cli_linux_amd64.zip"
      sha256 "c9290ec1efe4a70bbfbc99609b2f93463f916455c3ca45dbab0bad4775d2935d"
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
