# typed: false
# frozen_string_literal: true

class HardchargerOdbc < Formula
  desc "Hardcharger ODBC driver using native Chargewire and Arrow streaming"
  homepage "https://github.com/gizmodata/hardcharger-odbc-driver"
  version "1.3.0"
  license "Apache-2.0"
  depends_on "unixodbc"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/gizmodata/hardcharger-odbc-driver/releases/download/v1.3.0/hardcharger-odbc-macos-arm64.tar.gz"
      sha256 "a2db73faccb06e3715e77ab24f2953f840adf30d3ed123c61111f97702b8a8a7"
    end
  end
  on_linux do
    depends_on "patchelf" => :build
    on_intel do
      url "https://github.com/gizmodata/hardcharger-odbc-driver/releases/download/v1.3.0/hardcharger-odbc-linux-amd64.tar.gz"
      sha256 "0877c749b3e5be5e8bdac25aa379a68e4e7613d2c799477383c7aca82731277d"
    end
    on_arm do
      url "https://github.com/gizmodata/hardcharger-odbc-driver/releases/download/v1.3.0/hardcharger-odbc-linux-arm64.tar.gz"
      sha256 "8a19858c0c945fa9aea11243e8e7f400a57a1d7f3a5d6e837fa463b3e19de121"
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

