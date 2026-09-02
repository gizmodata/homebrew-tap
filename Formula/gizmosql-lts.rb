# typed: false
# frozen_string_literal: true

# GizmoSQL LTS — built against the DuckDB LTS release.
# Installs as gizmosql_server_lts / gizmosql_client_lts so it can
# coexist with the regular `gizmosql` formula side-by-side.
class GizmosqlLts < Formula
  desc "GizmoSQL (LTS channel) — Flight SQL server on the DuckDB LTS release"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.38.1"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.38.1/gizmosql_cli_macos_arm64_lts.zip"
      sha256 "dd9047746588653f384aefb450f4b272207907bc4259750522facd9a22ebb95c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.38.1/gizmosql_cli_linux_arm64_lts.zip"
      sha256 "a07f744100814aa5acb097b09cd301bda38236d764c1a72f70c0f41a78c0195d"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.38.1/gizmosql_cli_linux_amd64_lts.zip"
      sha256 "000c04afac923f470c5587f95c883a1cac35ff79e1fe31732d2d68310d2f1a83"
    end
  end

  def install
    bin.install "gizmosql_server_lts"
    bin.install "gizmosql_client_lts"
  end

  def caveats
    <<~EOS
      LTS channel binaries install as gizmosql_server_lts and gizmosql_client_lts.

      Start a GizmoSQL LTS server:
        GIZMOSQL_PASSWORD=tiger gizmosql_server_lts --database-filename my_database.duckdb --username scott

      Connect with the interactive SQL shell:
        GIZMOSQL_PASSWORD=tiger gizmosql_client_lts --host localhost --username scott

      For TLS and authentication options, see:
        gizmosql_server_lts --help
        gizmosql_client_lts --help
    EOS
  end

  test do
    assert_match "gizmosql_server", shell_output("#{bin}/gizmosql_server_lts --help 2>&1", 1)
  end
end
