#! /usr/bin/env ruby
# coding: utf-8

require "helper"
#require "test/unit"
#require "pkg/klass.rb"

class FileRenamer::FileTreeSimulator
  attr_reader :files
end

class TC_FileTreeSimulator < Test::Unit::TestCase
  #ORIG_DIR = "test/filetreesimulator/orig"
  #TMP_DIR = "test/filetreesimulator/tmp"

  def setup
    #FileUtils.cp_r(ORIG_DIR, TMP_DIR)
    @fts = FileRenamer::FileTreeSimulator.new
  end

  def teardown
    #FileUtils.rm_rf(TMP_DIR) if File.exist? TMP_DIR
  end

  #def test_

  def test_mv
    #test/filetreesimulator/00
    #test/filetreesimulator/dir00
    #test/filetreesimulator/dir00/01
    #test/filetreesimulator/dir00/02

    @fts.mv("test/filetreesimulator/00", "test/filetreesimulator/01")
    assert_equal( {
      "test/filetreesimulator/00" => false,
      "test/filetreesimulator/01" => :file
      },
      @fts.files
    )

    @fts.mv("test/filetreesimulator/dir00", "test/filetreesimulator/dir01")
    assert_equal( {
      "test/filetreesimulator/00" => false,
      "test/filetreesimulator/01" => :dir
      },
      @fts.files
    )

    @fts.mv("test/filetreesimulator/dir01", "test/filetreesimulator/dir02")
    assert_equal( {
      "test/filetreesimulator/00" => false,
      "test/filetreesimulator/01" => false,
      "test/filetreesimulator/02" => :dir
      },
      @fts.files
    )
  end

  def test_cp
  end

  def test_ln
  end

  def test_ln_s
  end

  def test_mkdir_p
  end

  def test_rmdir_p
  end

  def test_rm
  end


end

