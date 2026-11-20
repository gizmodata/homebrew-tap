# typed: false
# frozen_string_literal: true

class ChargewireOdbc < Formula
  desc "Chargewire ODBC driver using native Chargewire and Arrow streaming"
  homepage "https://github.com/gizmodata/chargewire-odbc"
  version "2.5.1"
  license "Apache-2.0"
  depends_on "unixodbc"

  on_macos do
    depends_on macos: :sequoia
    on_arm do
      url "https://github.com/gizmodata/chargewire-odbc/releases/download/v2.5.1/chargewire-odbc-macos-arm64.tar.gz"
      sha256 "5e188459f23d0c5b8aa6a29f494dbb7d714bc02082d7fe0253f35aea8f1f176e"
    end
  end
  on_linux do
    depends_on "patchelf" => :build
    on_intel do
      url "https://github.com/gizmodata/chargewire-odbc/releases/download/v2.5.1/chargewire-odbc-linux-amd64.tar.gz"
      sha256 "d25f7fb39e38b7f19686e8f43647b12e85217202c0808e35f257b3a43110dcc2"
    end
    on_arm do
      url "https://github.com/gizmodata/chargewire-odbc/releases/download/v2.5.1/chargewire-odbc-linux-arm64.tar.gz"
      sha256 "1c40e62ef39d6a0fc45f820d4ee8ef29d56502064852d63bea8859cd37cacf5d"
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

