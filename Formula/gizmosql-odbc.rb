# typed: false
# frozen_string_literal: true

class GizmosqlOdbc < Formula
  desc "GizmoSQL ODBC Driver"
  homepage "https://gizmodata.com/gizmosql"
  version "1.0.0"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql-odbc-driver/releases/download/v1.0.0/libgizmosql-odbc-macos-arm64.dylib"
      sha256 "3a17e0fe76d0f72ec998ac9a1dfda3f800da8984e72411ea2739fe26c8cc9f10"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/gizmodata/gizmosql-odbc-driver/releases/download/v1.0.0/libgizmosql-odbc-linux-arm64.so"
      sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
    elsif Hardware::CPU.intel?
      url "https://github.com/gizmodata/gizmosql-odbc-driver/releases/download/v1.0.0/libgizmosql-odbc-linux-x64.so"
      sha256 "9d73dba284e9161c26c09f81610cf605ed64a8e7bcf1c9fd0f078a2aa4d41c69"
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

  def caveats
    if OS.mac?
      <<~EOS
        To register the driver, add the following to /usr/local/etc/odbcinst.ini:

[GizmoSQL ODBC Driver]
Driver = #{lib}/libgizmosql-odbc.dylib

        Then add a DSN to ~/.odbc.ini:

[GizmoSQL]
Driver        = GizmoSQL ODBC Driver
host          = localhost
port          = 32010
uid           = your-username
pwd           = your-password
useEncryption = true
      EOS
    else
      <<~EOS
        To register the driver, add the following to /etc/odbcinst.ini:

[GizmoSQL ODBC Driver]
Driver = #{lib}/libgizmosql-odbc.so

        Then add a DSN to ~/.odbc.ini:

[GizmoSQL]
Driver        = GizmoSQL ODBC Driver
host          = localhost
port          = 32010
uid           = your-username
pwd           = your-password
useEncryption = true
      EOS
    end
  end

  test do
    if OS.mac?
      assert_predicate lib/"libgizmosql-odbc.dylib", :exist?
    else
      assert_predicate lib/"libgizmosql-odbc.so", :exist?
    end
  end
end
