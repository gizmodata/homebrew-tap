# typed: false
# frozen_string_literal: true

class Gizmosql < Formula
  desc "High-performance SQL server built on DuckDB/SQLite with Arrow Flight SQL"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.41.0"
  license "Apache-2.0"

  on_macos do
    depends_on macos: :sequoia
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.41.0/gizmosql_cli_macos_arm64.zip"
      sha256 "f644696ae3b9a8834ef6d5531c5bebe28dbf67f6a0067ce12cc0690d41a93f98"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.41.0/gizmosql_cli_linux_arm64.zip"
      sha256 "664bf172587dc237613205c4ec9510ac68e0ff9a996d240371110b1f6371f060"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.41.0/gizmosql_cli_linux_amd64.zip"
      sha256 "27a525434937b2951c7a15f24361f82f1fb23b475f5b4340365da7698d0dee95"
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
