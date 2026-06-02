# typed: false
# frozen_string_literal: true

# GizmoSQL LTS — built against the DuckDB LTS release.
# Installs as gizmosql_server_lts / gizmosql_client_lts so it can
# coexist with the regular `gizmosql` formula side-by-side.
class GizmosqlLts < Formula
  desc "GizmoSQL (LTS channel) — Flight SQL server on the DuckDB LTS release"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.27.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.27.0/gizmosql_cli_macos_arm64_lts.zip"
      sha256 "2b592f7264b87e44eb0f0dc9e5c8a050ea6896821c24d09e04a3ba319024b8c7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.27.0/gizmosql_cli_linux_arm64_lts.zip"
      sha256 "314cfd7c4a92909838a52687237fbb60a4f5ccca7ab3172c6ade827b2a0c7157"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.27.0/gizmosql_cli_linux_amd64_lts.zip"
      sha256 "2315dfcf472b1e173f65f7b291f6e641d229ae99e2f46de76ddcb665bfe53962"
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
