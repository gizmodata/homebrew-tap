# typed: false
# frozen_string_literal: true

class HardchargerOdbc < Formula
  desc "Hardcharger ODBC driver using native Chargewire and Arrow streaming"
  homepage "https://github.com/gizmodata/hardcharger-odbc-driver"
  version "1.4.0"
  license "Apache-2.0"
  depends_on "unixodbc"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/gizmodata/hardcharger-odbc-driver/releases/download/v1.4.0/hardcharger-odbc-macos-arm64.tar.gz"
      sha256 "c34c2336e6811f7dd46619008eadc1aeaf4749762cbc1d7dea8791ecff1e380d"
    end
  end
  on_linux do
    depends_on "patchelf" => :build
    on_intel do
      url "https://github.com/gizmodata/hardcharger-odbc-driver/releases/download/v1.4.0/hardcharger-odbc-linux-amd64.tar.gz"
      sha256 "6a296e430a638bdd7412c28692a0f3fa7cd01f7510e7cfbe99fa2ead2e7c6e5c"
    end
    on_arm do
      url "https://github.com/gizmodata/hardcharger-odbc-driver/releases/download/v1.4.0/hardcharger-odbc-linux-arm64.tar.gz"
      sha256 "32528c1c61eb8e793a7e91f84ed0e8ada5df244b2f2af78c5f171f758e140a4f"
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

