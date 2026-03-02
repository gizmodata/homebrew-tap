# typed: false
# frozen_string_literal: true

class GizmosqlOdbc < Formula
  desc "GizmoSQL ODBC Driver"
  homepage "https://gizmodata.com/gizmosql"
  version "1.1.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql-odbc-driver/releases/download/v1.1.0/libgizmosql-odbc-macos-arm64.dylib"
      sha256 "28efbcaab9cbb9d8474b727ae8446c796ad443449d7551c7c8078c09c5a0327d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql-odbc-driver/releases/download/v1.1.0/libgizmosql-odbc-linux-arm64.so"
      sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql-odbc-driver/releases/download/v1.1.0/libgizmosql-odbc-linux-x64.so"
      sha256 "2eb832ebeb354c8abdd22193ad1a0dac9e80d6b1592778f6e12d1df49e170870"
    end
  end

  def install
    if OS.mac?
      lib.install "libgizmosql-odbc-macos-arm64.dylib" => "libgizmosql-odbc.dylib"
    elsif OS.linux?
      if Hardware::CPU.arm?
        lib.install "libgizmosql-odbc-linux-arm64.so" => "libgizmosql-odbc.so"
      else
        lib.install "libgizmosql-odbc-linux-x64.so" => "libgizmosql-odbc.so"
      end
    end
  end

  def post_install
    odbcinst_ini = etc/"odbcinst.ini"
    driver_name = "GizmoSQL ODBC Driver"

    if OS.mac?
      driver_path = lib/"libgizmosql-odbc.dylib"
    else
      driver_path = lib/"libgizmosql-odbc.so"
    end

    if odbcinst_ini.exist?
      contents = odbcinst_ini.read
      if contents.include?("[#{driver_name}]")
        # Update existing driver entry with new path
        contents.gsub!(/(\[#{Regexp.escape(driver_name)}\]\s*\nDriver\s*=\s*).*/, "\1#{driver_path}")
        odbcinst_ini.atomic_write(contents)
      else
        # Append new driver entry to existing file
        odbcinst_ini.open("a") do |f|
f.puts "" unless contents.end_with?("\n\n")
f.puts "[ODBC Drivers]" unless contents.include?("[ODBC Drivers]")
f.puts ""
f.puts "[#{driver_name}]"
f.puts "Driver = #{driver_path}"
        end
      end
    else
      odbcinst_ini.write <<~EOS
        [ODBC Drivers]
        #{driver_name} = Installed

        [#{driver_name}]
        Driver = #{driver_path}
      EOS
    end
  end

  def caveats
    <<~EOS
      The driver has been registered automatically.

      To create a DSN, add the following to ~/.odbc.ini:

        [GizmoSQL]
        Driver        = GizmoSQL ODBC Driver
        host          = localhost
        port          = 32010
        uid           = your-username
        pwd           = your-password
        useEncryption = true
    EOS
  end

  test do
    if OS.mac?
      assert_predicate lib/"libgizmosql-odbc.dylib", :exist?
    else
      assert_predicate lib/"libgizmosql-odbc.so", :exist?
    end
  end
end
