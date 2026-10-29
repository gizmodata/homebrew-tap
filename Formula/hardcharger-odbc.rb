# typed: false
# frozen_string_literal: true

class HardchargerOdbc < Formula
  desc "Hardcharger ODBC driver using native Chargewire and Arrow streaming"
  homepage "https://github.com/gizmodata/hardcharger-odbc-driver"
  version "1.1.0"
  license "Apache-2.0"
  depends_on "unixodbc"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/gizmodata/hardcharger-odbc-driver/releases/download/v1.1.0/hardcharger-odbc-macos-arm64.tar.gz"
      sha256 "f6470eda32db959c611aa825d574a91016aefd97cd949c8381ad68c66c831034"
    end
  end
  on_linux do
    depends_on "patchelf" => :build
    on_intel do
      url "https://github.com/gizmodata/hardcharger-odbc-driver/releases/download/v1.1.0/hardcharger-odbc-linux-amd64.tar.gz"
      sha256 "8624c1914116fe1029c4bc51bc35cc1c220a72328c7aac229e2e163e8b4ead12"
    end
    on_arm do
      url "https://github.com/gizmodata/hardcharger-odbc-driver/releases/download/v1.1.0/hardcharger-odbc-linux-arm64.tar.gz"
      sha256 "ef9b2783e75f9c7a6b755e577c371d4adf89f5f84cc5b6ae9fbef0b90a9f993a"
    end
  end

  def install
    lib.install Dir["lib/*"]
    if OS.linux?
      system "patchelf", "--add-rpath", Formula["unixodbc"].opt_lib.to_s, lib/"libhardcharger-odbc.so"
    end
    pkgshare.install Dir["share/hardcharger-odbc/*"]
  end

  def post_install
    ini = etc/"odbcinst.ini"
    name = "Hardcharger ODBC Driver"
    path = lib/(OS.mac? ? "libhardcharger-odbc.dylib" : "libhardcharger-odbc.so")
    text = ini.exist? ? ini.read : ""
    if text.match?(/^\[#{Regexp.escape(name)}\]$/)
      # Replace only this driver's section, preserving other drivers.
      text.gsub!(/^\[#{Regexp.escape(name)}\]\n[^\[]*/, "[#{name}]\nDriver = #{path}\n\n")
    else
      text += "\n[#{name}]\nDriver = #{path}\n"
    end
    ini.atomic_write(text)
  end

  def caveats
    <<~EOS
      Driver registered as Hardcharger ODBC Driver. Add a DSN to ~/.odbc.ini:

        [Hardcharger]
        Driver = Hardcharger ODBC Driver
        host = localhost
        port = 31337
        uid = your-username
        pwd = your-password
        useEncryption = true

      Linux packages require glibc 2.39 or later (Ubuntu 24.04 or equivalent).
    EOS
  end

  test do
    path = lib/(OS.mac? ? "libhardcharger-odbc.dylib" : "libhardcharger-odbc.so")
    assert_path_exists path
    assert_match "Hardcharger ODBC Driver", shell_output("#{Formula["unixodbc"].opt_bin}/odbcinst -q -d")
  end
end

