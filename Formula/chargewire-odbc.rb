# typed: false
# frozen_string_literal: true

class ChargewireOdbc < Formula
  desc "Chargewire ODBC driver using native Chargewire and Arrow streaming"
  homepage "https://github.com/gizmodata/chargewire-odbc"
  version "2.3.1"
  license "Apache-2.0"
  depends_on "unixodbc"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/gizmodata/chargewire-odbc/releases/download/v2.3.1/chargewire-odbc-macos-arm64.tar.gz"
      sha256 "43d75079e07bc338e9bc9d1a19a765b73ef4c9dc64bd68d322b56ebb81854fb7"
    end
  end
  on_linux do
    depends_on "patchelf" => :build
    on_intel do
      url "https://github.com/gizmodata/chargewire-odbc/releases/download/v2.3.1/chargewire-odbc-linux-amd64.tar.gz"
      sha256 "469a8e83dc9cde4478c4c4089634dea081bca48fd7b95ea586cecdea5b8fe009"
    end
    on_arm do
      url "https://github.com/gizmodata/chargewire-odbc/releases/download/v2.3.1/chargewire-odbc-linux-arm64.tar.gz"
      sha256 "784353b43f783f05aca4f330a91f603879ea5fefd6641c68d6f77e280c644566"
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

