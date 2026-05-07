# typed: false
# frozen_string_literal: true

# GizmoSQL LTS — built against the DuckDB LTS release.
# Installs as gizmosql_server_lts / gizmosql_client_lts so it can
# coexist with the regular `gizmosql` formula side-by-side.
class GizmosqlLts < Formula
  desc "GizmoSQL (LTS channel) — Flight SQL server on the DuckDB LTS release"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.25.1"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.25.1/gizmosql_cli_macos_arm64_lts.zip"
      sha256 "ed3454f5aa76bb5964a83609e75f995d33ec273ce00d00e8811ad2f52c13492d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.25.1/gizmosql_cli_linux_arm64_lts.zip"
      sha256 "19d5e4cd405e4d9db6b9387f5503b07652f8de1f49be6b02d832f2dbc949e4ff"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.25.1/gizmosql_cli_linux_amd64_lts.zip"
      sha256 "a04e2edfa9ebeb635219b807388518dcd4933eea624b7ac3f82b906a836e72ef"
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
