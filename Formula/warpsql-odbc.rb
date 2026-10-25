# typed: false
# frozen_string_literal: true

class WarpsqlOdbc < Formula
  desc "Warp SQL ODBC driver using native Warp SQL and Arrow streaming"
  homepage "https://github.com/gizmodata/warp-sql-odbc"
  version "1.0.0"
  license "Apache-2.0"
  depends_on "unixodbc"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/gizmodata/warp-sql-odbc/releases/download/v1.0.0/warpsql-odbc-macos-arm64.tar.gz"
      sha256 "66e7ad2e7c2740c2866f4913c8108d5f403f0953389c3c2179d09ed86f2d8666"
    end
  end
  on_linux do
    depends_on "patchelf" => :build
    on_intel do
      url "https://github.com/gizmodata/warp-sql-odbc/releases/download/v1.0.0/warpsql-odbc-linux-amd64.tar.gz"
      sha256 "3fa2df2c36c83ee5b009e07255860c82e96cdab0e665e54b94464b76fa45f04a"
    end
    on_arm do
      url "https://github.com/gizmodata/warp-sql-odbc/releases/download/v1.0.0/warpsql-odbc-linux-arm64.tar.gz"
      sha256 "1dacfc5560bdf18b609e7f0594ece53cc41bab0a4389a790b18308de4e757731"
    end
  end

  def install
    lib.install Dir["lib/*"]
    if OS.linux?
      system "patchelf", "--add-rpath", Formula["unixodbc"].opt_lib.to_s, lib/"libwarpsql-odbc.so"
    end
    pkgshare.install Dir["share/warpsql-odbc/*"]
  end

  def post_install
    ini = etc/"odbcinst.ini"
    name = "Warp SQL ODBC Driver"
    path = lib/(OS.mac? ? "libwarpsql-odbc.dylib" : "libwarpsql-odbc.so")
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
      Driver registered as Warp SQL ODBC Driver. Add a DSN to ~/.odbc.ini:

        [Warp SQL]
        Driver = Warp SQL ODBC Driver
        host = localhost
        port = 31337
        uid = your-username
        pwd = your-password
        useEncryption = true

      Linux packages require glibc 2.39 or later (Ubuntu 24.04 or equivalent).
    EOS
  end

  test do
    path = lib/(OS.mac? ? "libwarpsql-odbc.dylib" : "libwarpsql-odbc.so")
    assert_path_exists path
    assert_match "Warp SQL ODBC Driver", shell_output("#{Formula["unixodbc"].opt_bin}/odbcinst -q -d")
  end
end

