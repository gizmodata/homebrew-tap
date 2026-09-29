# typed: false
# frozen_string_literal: true

# GizmoSQL LTS — built against the DuckDB LTS release.
# Installs as gizmosql_server_lts / gizmosql_client_lts so it can
# coexist with the regular `gizmosql` formula side-by-side.
class GizmosqlLts < Formula
  desc "GizmoSQL (LTS channel) — Flight SQL server on the DuckDB LTS release"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.40.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.40.0/gizmosql_cli_macos_arm64_lts.zip"
      sha256 "6382d2990381b3c8a70256f71a3698794b614659ab1757b2574e1b07725c12de"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.40.0/gizmosql_cli_linux_arm64_lts.zip"
      sha256 "a258bb5fb320775f740ee53866d71f875b576ca254b1b8163a7564d23dbf1f31"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.40.0/gizmosql_cli_linux_amd64_lts.zip"
      sha256 "43083137b298ce3ad6b260d7ae527596b135fc223e4b5930e6c6f09613d75985"
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
