# typed: false
# frozen_string_literal: true

# GizmoSQL LTS — built against the DuckDB LTS release.
# Installs as gizmosql_server_lts / gizmosql_client_lts so it can
# coexist with the regular `gizmosql` formula side-by-side.
class GizmosqlLts < Formula
  desc "GizmoSQL (LTS channel) — Flight SQL server on the DuckDB LTS release"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.30.1"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.30.1/gizmosql_cli_macos_arm64_lts.zip"
      sha256 "71668ae05a4cb731c68591843dc014d1638cb49dd4b6cec52ca37e1124223451"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.30.1/gizmosql_cli_linux_arm64_lts.zip"
      sha256 "49abf222f966d52d16ae5a76c4bede43b4438bc73c37036e96a6d04f444f09c3"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.30.1/gizmosql_cli_linux_amd64_lts.zip"
      sha256 "1a5d70fe0d7a250d1065311847eee31c15f91d005b66e3c624103bbe18bcb3ba"
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
