# typed: false
# frozen_string_literal: true

# GizmoSQL edge — EXPERIMENTAL, built against a DuckDB pre-release
# (the next DuckDB major). Not for production workloads.
# Installs as gizmosql_server_edge / gizmosql_client_edge so it can
# coexist with the `gizmosql` and `gizmosql-lts` formulas.
class GizmosqlEdge < Formula
  desc "GizmoSQL (edge channel, experimental) — Flight SQL server on a DuckDB pre-release"
  homepage "https://docs.gizmosql.com/edge_channel/"
  version "1.41.0"
  license "Apache-2.0"

  on_macos do
    depends_on macos: :sequoia
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.41.0/gizmosql_cli_macos_arm64_edge.zip"
      sha256 "5296c1f78870940f3ae7bfc629b1a41afe3e5201b70775bfc29ab7ee94ff8689"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.41.0/gizmosql_cli_linux_arm64_edge.zip"
      sha256 "0ad0768fdda1cc032692938ffb114a22f3881041e0638bcf35b9577e883ea558"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.41.0/gizmosql_cli_linux_amd64_edge.zip"
      sha256 "cb92a99c090e9ab7929fb868b341bc18154963f02b1131fc355d6f766a63b876"
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
