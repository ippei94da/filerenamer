#! /usr/bin/env ruby
# coding: utf-8

require "helper"
#require "test/unit"
#require "pkg/klass.rb"

#class FileRenamer::FileTreeSimulator
#  attr_accessor :files
#  public :reflect_from_filesystem
#end
#
#class TC_FileTreeSimulator < Test::Unit::TestCase
#  #ORIG_DIR = "test/filetreesimulator/orig"
#  #TMP_DIR = "test/filetreesimulator/tmp"
#
#  def setup
#    #FileUtils.cp_r(ORIG_DIR, TMP_DIR)
#    @fts = FileRenamer::FileTreeSimulator.new
#  end
#
#  def teardown
#    #FileUtils.rm_rf(TMP_DIR) if File.exist? TMP_DIR
#  end
#
#  def test_mv
#    #test/filetreesimulator/00
#    #test/filetreesimulator/dir00
#    #test/filetreesimulator/dir00/01
#    #test/filetreesimulator/dir00/02
#
#    @fts.mv("test/filetreesimulator/00", "test/filetreesimulator/01")
#    assert_equal( {
#      "#{ENV['PWD']}/test/filetreesimulator/00" => false,
#      "#{ENV['PWD']}/test/filetreesimulator/01" => :file
#      },
#      @fts.files
#    )
#
#    @fts.mv("test/filetreesimulator/dir00", "test/filetreesimulator/dir01")
#    assert_equal( {
#      "#{ENV['PWD']}/test/filetreesimulator/00" => false,
#      "#{ENV['PWD']}/test/filetreesimulator/01" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00" => false,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00/01" => false,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00/02" => false,
#      "#{ENV['PWD']}/test/filetreesimulator/dir01" => :directory,
#      "#{ENV['PWD']}/test/filetreesimulator/dir01/01" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir01/02" => :file,
#      },
#      @fts.files
#    )
#
#    @fts.mv("test/filetreesimulator/dir01", "test/filetreesimulator/dir02")
#    assert_equal( {
#      "#{ENV['PWD']}/test/filetreesimulator/00" => false,
#      "#{ENV['PWD']}/test/filetreesimulator/01" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00" => false,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00/01" => false,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00/02" => false,
#      "#{ENV['PWD']}/test/filetreesimulator/dir01" => false,
#      "#{ENV['PWD']}/test/filetreesimulator/dir01/01" => false,
#      "#{ENV['PWD']}/test/filetreesimulator/dir01/02" => false,
#      "#{ENV['PWD']}/test/filetreesimulator/dir02" => :directory,
#      "#{ENV['PWD']}/test/filetreesimulator/dir02/01" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir02/02" => :file,
#      },
#      @fts.files
#    )
#  end
#
#  def test_cp
#    @fts.cp_r("test/filetreesimulator/00", "test/filetreesimulator/01")
#    assert_equal( {
#      "#{ENV['PWD']}/test/filetreesimulator/00" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/01" => :file
#      },
#      @fts.files
#    )
#
#    @fts.cp_r("test/filetreesimulator/dir00", "test/filetreesimulator/dir01")
#    assert_equal( {
#      "#{ENV['PWD']}/test/filetreesimulator/00" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/01" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00" => :directory,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00/01" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00/02" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir01" => :directory,
#      "#{ENV['PWD']}/test/filetreesimulator/dir01/01" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir01/02" => :file,
#      },
#      @fts.files
#    )
#
#    @fts.cp_r("test/filetreesimulator/dir01", "test/filetreesimulator/dir02")
#    assert_equal( {
#      "#{ENV['PWD']}/test/filetreesimulator/00" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/01" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00" => :directory,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00/01" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00/02" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir01" => :directory,
#      "#{ENV['PWD']}/test/filetreesimulator/dir01/01" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir01/02" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir02" => :directory,
#      "#{ENV['PWD']}/test/filetreesimulator/dir02/01" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir02/02" => :file,
#      },
#      @fts.files
#    )
#  end
#
#  def test_ln
#    @fts.ln("test/filetreesimulator/00", "test/filetreesimulator/01")
#    assert_equal( {
#      "#{ENV['PWD']}/test/filetreesimulator/00" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/01" => :file
#      },
#      @fts.files
#    )
#
#    assert_raise(FileRenamer::FileTreeSimulator::NotPermittedOperationError){
#      @fts.ln("test/filetreesimulator/dir00", "test/filetreesimulator/dir01")
#    }
#  end
#
#  def test_ln_s
#    @fts.ln_s("test/filetreesimulator/00", "test/filetreesimulator/01")
#    assert_equal( {
#      "#{ENV['PWD']}/test/filetreesimulator/00" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/01" => :link
#      },
#      @fts.files
#    )
#
#    @fts.ln_s("test/filetreesimulator/dir00", "test/filetreesimulator/dir01")
#    assert_equal( {
#      "#{ENV['PWD']}/test/filetreesimulator/00" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/01" => :link,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00" => :directory,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00/01" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00/02" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir01" => :link,
#      },
#      @fts.files
#    )
#
#    @fts.ln_s("test/filetreesimulator/dir01", "test/filetreesimulator/dir02")
#    assert_equal( {
#      "#{ENV['PWD']}/test/filetreesimulator/00" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/01" => :link,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00" => :directory,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00/01" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir00/02" => :file,
#      "#{ENV['PWD']}/test/filetreesimulator/dir01" => :link,
#      "#{ENV['PWD']}/test/filetreesimulator/dir02" => :link,
#      },
#      @fts.files
#    )
#  end
#
#  def test_mkdir_p
#    @fts.mkdir("test/filetreesimulator/dir01/dir02")
#    assert_equal( {
#      "#{ENV['PWD']}/test/filetreesimulator/dir01" => :directory,
#      "#{ENV['PWD']}/test/filetreesimulator/dir02" => :directory,
#      },
#      @fts.files
#    )
#
#    assert_raise(AlreadyExistError) {
#      @fts.mkdir("test/filetreesimulator/dir01/dir02")
#    }
#  end
#
#  def test_rmdir_p
#  end
#
#  def test_rm
#  end
#
#  def test_reflect_from_filesystem
#    @fts.reflect_from_filesystem("test/filetreesimulator")
#    assert_equal(
#      {
#        "#{ENV['PWD']}/test/filetreesimulator" => :directory,
#        "#{ENV['PWD']}/test/filetreesimulator/00" => :file,
#        "#{ENV['PWD']}/test/filetreesimulator/dir00" => :directory,
#        "#{ENV['PWD']}/test/filetreesimulator/dir00/01" => :file,
#        "#{ENV['PWD']}/test/filetreesimulator/dir00/02" => :file,
#      },
#      @fts.files
#    )
#
#    @fts.reflect_from_filesystem("test/filetreesimulator/not_exist")
#    assert_equal(
#      {
#        "#{ENV['PWD']}/test/filetreesimulator" => :directory,
#        "#{ENV['PWD']}/test/filetreesimulator/00" => :file,
#        "#{ENV['PWD']}/test/filetreesimulator/dir00" => :directory,
#        "#{ENV['PWD']}/test/filetreesimulator/dir00/01" => :file,
#        "#{ENV['PWD']}/test/filetreesimulator/dir00/02" => :file,
#        "#{ENV['PWD']}/test/filetreesimulator/not_exist" => false,
#      },
#      @fts.files
#    )
#
#    @fts.files = { "#{ENV['PWD']}/test/filetreesimulator" => false }
#    @fts.reflect_from_filesystem("test/filetreesimulator")
#    assert_equal(
#      { "#{ENV['PWD']}/test/filetreesimulator" => false },
#      @fts.files
#    )
#
#  end
#
#end

