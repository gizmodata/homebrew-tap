# typed: false
# frozen_string_literal: true

# GizmoSQL edge — EXPERIMENTAL, built against the newest DuckDB
# major (DuckDB 2.0). Not for production workloads.
# Installs as gizmosql_server_edge / gizmosql_client_edge so it can
# coexist with the `gizmosql` and `gizmosql-lts` formulas.
class GizmosqlEdge < Formula
  desc "GizmoSQL (edge channel, experimental) — Flight SQL server on DuckDB 2.0"
  homepage "https://docs.gizmosql.com/edge_channel/"
  version "1.42.2"
  license "Apache-2.0"

  on_macos do
    depends_on macos: :sequoia
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.42.2/gizmosql_cli_macos_arm64_edge.zip"
      sha256 "2f3a80dca4cf2750e81442d374ecb110999030caff75c45168cc665009dfd31f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.42.2/gizmosql_cli_linux_arm64_edge.zip"
      sha256 "6752f6e4260d34422fc3ae76030967dc943696bb4f8316dabe0586715849d0bc"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.42.2/gizmosql_cli_linux_amd64_edge.zip"
      sha256 "b352d8e8400de320c1f6bc0ff58a0a459c1efc82ad49aa13b6bfa5b98b203173"
    end
  end

  def install
    bin.install "gizmosql_server_edge"
    bin.install "gizmosql_client_edge"
  end

  def caveats
    <<~EOS
      WARNING: the edge channel is EXPERIMENTAL and NOT meant for production
      workloads. It runs on the newest DuckDB major (2.0); behavior and
      extensions can change or break between releases, and database files it
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
