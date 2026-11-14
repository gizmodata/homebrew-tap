# typed: false
# frozen_string_literal: true

# The version, URLs and checksums below are rewritten by scripts/bump_hardcharger.py after each
# Hardcharger release; everything else is maintained here.
#
# `version` is explicit on purpose (`brew audit --strict` calls it redundant on macOS): from
# the URL alone, Homebrew reads the version of hardcharger-linux-arm64.tar.gz as "64".
class Hardcharger < Formula
  desc "Remote DuckDB 2.0 SQL server with its command-line client and web UI"
  homepage "https://github.com/gizmodata/hardcharger"
  version "2.12.1"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/gizmodata/hardcharger/releases/download/v2.12.1/hardcharger-macos-arm64.tar.gz"
      sha256 "8d02cfccb1a75c47c0028153dcc9434f583d119d8e758777298cd9c42983a7ed"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/gizmodata/hardcharger/releases/download/v2.12.1/hardcharger-linux-amd64.tar.gz"
      sha256 "38d683c0902bea20225888e04e06b0ef01f2ddc6278ddf83ea262a115a91ddd1"
    end
    on_arm do
      url "https://github.com/gizmodata/hardcharger/releases/download/v2.12.1/hardcharger-linux-arm64.tar.gz"
      sha256 "cd8f2743d4a5b94863ea56efe45b72c98a16e970bfae2df8caff1731e3065ec0"
    end
  end

  def install
    bin.install "bin/hardcharger", "bin/hardcharger-server"
    doc.install "THIRD_PARTY_NOTICES.md", "THIRD_PARTY_NOTICES-web-ui.txt"
  end

  def caveats
    <<~EOS
      Start a server on port 31337 (the administrator is "hardcharger"; without --database
      the database is in memory):
        HARDCHARGER_ADMIN_PASSWORD='change-me' hardcharger-server --database my.duckdb

      Connect with the SQL shell (--no-tls because the server above has no TLS certificate):
        HARDCHARGER_PASSWORD='change-me' hardcharger --no-tls --username hardcharger

      Or open the web UI on its own and add servers there:
        hardcharger ui

      If you also used the one-line installer (~/.hardcharger/bin), the directory that comes
      first in your PATH decides which hardcharger runs.

      Documentation: https://docs.hardcharger.gizmodata.com
    EOS
  end

  test do
    require "socket"

    assert_match version.to_s, shell_output("#{bin}/hardcharger --version")
    assert_match version.to_s, shell_output("#{bin}/hardcharger-server --version")

    port = free_port
    password = "brew-test-password"
    server = spawn({ "HARDCHARGER_ADMIN_PASSWORD" => password },
                   bin/"hardcharger-server", "--host", "127.0.0.1", "--port", port.to_s,
                   "--admin-username", "brew", "--database", ":memory:",
                   "--shutdown-grace-period-seconds", "5")
    begin
      listening = 60.times.any? do
        TCPSocket.new("127.0.0.1", port).close
        true
      rescue SystemCallError
        sleep 0.5
        false
      end
      assert listening, "hardcharger-server did not start listening on port #{port}"

      output = with_env("HARDCHARGER_PASSWORD" => password) do
        shell_output("#{bin}/hardcharger --host 127.0.0.1 --port #{port} --no-tls --username brew " \
                     "--no-init --quiet --csv --command 'SELECT 6 * 7 AS answer'")
      end
      assert_match "answer", output
      assert_match "42", output
    ensure
      Process.kill("TERM", server)
      Process.wait(server)
    end
  end
end
