# typed: false
# frozen_string_literal: true

class ChargewireOdbc < Formula
  desc "Chargewire ODBC driver using native Chargewire and Arrow streaming"
  homepage "https://github.com/gizmodata/chargewire-odbc"
  version "2.2.0"
  license "Apache-2.0"
  depends_on "unixodbc"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/gizmodata/chargewire-odbc/releases/download/v2.2.0/chargewire-odbc-macos-arm64.tar.gz"
      sha256 "8bba8de65f9a174839a8d5a26b4965b5ffa1d709060339ce4884e1071eb790a5"
    end
  end
  on_linux do
    depends_on "patchelf" => :build
    on_intel do
      url "https://github.com/gizmodata/chargewire-odbc/releases/download/v2.2.0/chargewire-odbc-linux-amd64.tar.gz"
      sha256 "bb4016f058f3a2763d30244f8e6096cefc270e2cc8d2529943479d266531de4a"
    end
    on_arm do
      url "https://github.com/gizmodata/chargewire-odbc/releases/download/v2.2.0/chargewire-odbc-linux-arm64.tar.gz"
      sha256 "51841e63d514b1c653a29b100f67be5e769a967fe7330a2ed28e47960c544b07"
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

