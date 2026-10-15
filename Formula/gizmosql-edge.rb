# typed: false
# frozen_string_literal: true

# GizmoSQL edge — EXPERIMENTAL, built against a DuckDB pre-release
# (the next DuckDB major). Not for production workloads.
# Installs as gizmosql_server_edge / gizmosql_client_edge so it can
# coexist with the `gizmosql` and `gizmosql-lts` formulas.
class GizmosqlEdge < Formula
  desc "GizmoSQL (edge channel, experimental) — Flight SQL server on a DuckDB pre-release"
  homepage "https://docs.gizmosql.com/edge_channel/"
  version "1.42.0"
  license "Apache-2.0"

  on_macos do
    depends_on macos: :sequoia
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.42.0/gizmosql_cli_macos_arm64_edge.zip"
      sha256 "b09d229d72b3a3545dfa83174be6cb1d7823f4a97a5a4a7b33ab3e1f4ef5271f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.42.0/gizmosql_cli_linux_arm64_edge.zip"
      sha256 "73fed40fdefa9f9b8dc36f2b43e0e6a47a50dce72a3e2dbcb04370cd836241cb"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.42.0/gizmosql_cli_linux_amd64_edge.zip"
      sha256 "df81101e22586f6017c15b20569d1ffaec89ff8456de50363b404986279898a7"
    end
  end

  def install
    bin.install "gizmosql_server_edge"
    bin.install "gizmosql_client_edge"
  end

  def caveats
    <<~EOS
      WARNING: the edge channel is EXPERIMENTAL and NOT meant for production
      workloads. It runs on a DuckDB pre-release; behavior, storage format and
      extensions can change or break between builds, and database files it
      creates cannot be opened by the stable or LTS channels. See:
        https://docs.gizmosql.com/edge_channel/

      Edge channel binaries install as gizmosql_server_edge and gizmosql_client_edge.

      Start a GizmoSQL edge server:
        GIZMOSQL_PASSWORD=tiger gizmosql_server_edge --database-filename my_database.duckdb --username scott

      Connect with the interactive SQL shell:
        GIZMOSQL_PASSWORD=tiger gizmosql_client_edge --host localhost --username scott
    EOS
  end

  test do
    assert_match "gizmosql_server", shell_output("#{bin}/gizmosql_server_edge --help 2>&1", 1)
  end
end
