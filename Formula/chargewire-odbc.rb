# typed: false
# frozen_string_literal: true

class ChargewireOdbc < Formula
  desc "Chargewire ODBC driver using native Chargewire and Arrow streaming"
  homepage "https://github.com/gizmodata/chargewire-odbc"
  version "2.3.2"
  license "Apache-2.0"
  depends_on "unixodbc"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/gizmodata/chargewire-odbc/releases/download/v2.3.2/chargewire-odbc-macos-arm64.tar.gz"
      sha256 "463970e8be2275ed78781edad7e4d231d869a8249940fb2410010537e289102a"
    end
  end
  on_linux do
    depends_on "patchelf" => :build
    on_intel do
      url "https://github.com/gizmodata/chargewire-odbc/releases/download/v2.3.2/chargewire-odbc-linux-amd64.tar.gz"
      sha256 "d3717864f1051004a44d43cd67fe1aebf53aaa8cb6f09d959ac8c6157c5930f3"
    end
    on_arm do
      url "https://github.com/gizmodata/chargewire-odbc/releases/download/v2.3.2/chargewire-odbc-linux-arm64.tar.gz"
      sha256 "1f2752da802979bd9794cff637f2d76330b2eaa0abee267107d5cb9a23c431b2"
    end
  end

  def install
    lib.install Dir["lib/*"]
    if OS.linux?
      system "patchelf", "--add-rpath", Formula["unixodbc"].opt_lib.to_s, lib/"libchargewire-odbc.so"
    end
    pkgshare.install Dir["share/chargewire-odbc/*"]
  end

  def post_install
    ini = etc/"odbcinst.ini"
    name = "Chargewire ODBC Driver"
    path = lib/(OS.mac? ? "libchargewire-odbc.dylib" : "libchargewire-odbc.so")
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
      Driver registered as Chargewire ODBC Driver. Add a DSN to ~/.odbc.ini:

        [Chargewire]
        Driver = Chargewire ODBC Driver
        host = localhost
        port = 31337
        uid = your-username
        pwd = your-password
        useEncryption = true

      Linux packages require glibc 2.39 or later (Ubuntu 24.04 or equivalent).
    EOS
  end

  test do
    path = lib/(OS.mac? ? "libchargewire-odbc.dylib" : "libchargewire-odbc.so")
    assert_path_exists path
    assert_match "Chargewire ODBC Driver", shell_output("#{Formula["unixodbc"].opt_bin}/odbcinst -q -d")
  end
end

