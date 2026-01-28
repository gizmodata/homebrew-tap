# typed: false
# frozen_string_literal: true

class Gizmosql < Formula
  desc "High-performance SQL server built on DuckDB/SQLite with Arrow Flight SQL"
  homepage "https://github.com/gizmodata/gizmosql"
  version "1.16.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.16.0/gizmosql_cli_macos_arm64.zip"
      sha256 "aad846d73d786a5b60aaac4bbd076089880729b7a6b8938288ed53a3b95fa435"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.16.0/gizmosql_cli_linux_arm64.zip"
      sha256 "7c8fbc80e3528059baeba07d2c082d22c05c9676a8d9154c4685b830f30eb143"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql/releases/download/v1.16.0/gizmosql_cli_linux_amd64.zip"
      sha256 "b41dfb88a4a988616d0526be6aadad3079802220b2fed10f6c3326fec0390a75"
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
