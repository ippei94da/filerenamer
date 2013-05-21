#! /usr/bin/env ruby
# coding: utf-8

require "helper"
require "fileutils"
require "stringio"
#require "test/unit"
#require "pkg/klass.rb"

class TC_Lns < Test::Unit::TestCase
  ORIG_DIR = "test/manipulation/lns/orig"
  TMP_DIR = "test/manipulation/lns/tmp"
  FROM_FILE = "#{TMP_DIR}/00"
  TO_FILE ="#{TMP_DIR}/01"

  FROM_DIR = "#{TMP_DIR}/dir00"
  TO_DIR ="#{TMP_DIR}/dir01"

  def setup
    FileUtils.cp_r(ORIG_DIR, TMP_DIR)
    @s00 = FileRenamer::Manipulation::Lns.new(FROM_FILE, TO_FILE)

    @s01 = FileRenamer::Manipulation::Lns.new(FROM_DIR, TO_DIR)
  end

  def teardown
    FileUtils.rm_rf(TMP_DIR) if File.exist? TMP_DIR
  end

  def test_initialize
    assert_raise(FileRenamer::Manipulation::Lns::ArgumentError){
      FileRenamer::Manipulation::Lns.new
    }
    assert_raise(FileRenamer::Manipulation::Lns::ArgumentError){
      FileRenamer::Manipulation::Lns.new("#{TMP_DIR}/00")
    }
    assert_raise(FileRenamer::Manipulation::Lns::ArgumentError){
      FileRenamer::Manipulation::Lns.new("#{TMP_DIR}/00",
                                        "#{TMP_DIR}/01",
                                        "#{TMP_DIR}/02")
    }
  end

  def test_vanishing_files
    assert_equal([], @s00.vanishing_files)

    assert_equal([], @s01.vanishing_files)
  end

  def test_appearing_files
    assert_equal([TO_FILE], @s00.appearing_files)

    assert_equal( [TO_DIR], @s01.appearing_files)
  end

  def test_execute_with_io
    assert_equal(true , File.exist?(FROM_FILE))
    assert_equal(false, File.exist?(TO_FILE))
    io = StringIO.new
    @s00.execute(io)
    assert_equal(true , File.exist?(FROM_FILE))
    assert_equal(true , File.symlink?(TO_FILE))

    assert_equal(true , File.exist?(FROM_DIR))
    assert_equal(true , File.exist?(FROM_DIR + "/01"))
    assert_equal(true , File.exist?(FROM_DIR + "/02"))
    assert_equal(false, File.exist?(TO_DIR))
    io = StringIO.new
    @s01.execute(io)
    assert_equal(true , File.exist?(FROM_DIR))
    assert_equal(true , File.exist?(FROM_DIR + "/01"))
    assert_equal(true , File.exist?(FROM_DIR + "/02"))
    #assert_equal(true , File.exist?(TO_DIR))
    assert_equal(true , File.symlink?(TO_DIR))
    #assert_equal(true , File.exist?(TO_DIR + "/01"))
    #assert_equal(true , File.exist?(TO_DIR + "/02"))
  end

  def test_execute_without_io
    assert_equal(true , File.exist?(FROM_FILE))
    assert_equal(false, File.exist?(TO_FILE))
    @s00.execute
    #sleep 60
    assert_equal(true , File.exist?(FROM_FILE))
    #assert_equal(true , File.exist?(TO_FILE))
    assert_equal(true , File.symlink?(TO_FILE))

    assert_equal(true , File.exist?(FROM_DIR))
    assert_equal(true , File.exist?(FROM_DIR + "/01"))
    assert_equal(true , File.exist?(FROM_DIR + "/02"))
    assert_equal(false, File.exist?(TO_DIR))
    @s01.execute
    assert_equal(true , File.exist?(FROM_DIR))
    assert_equal(true , File.exist?(FROM_DIR + "/01"))
    assert_equal(true , File.exist?(FROM_DIR + "/02"))
    #assert_equal(true , File.exist?(TO_DIR))
    assert_equal(true , File.symlink?(TO_DIR))
    #assert_equal(true , File.exist?(TO_DIR + "/01"))
    #assert_equal(true , File.exist?(TO_DIR + "/02"))
  end

  def test_to_s
    assert_equal("ln -s #{FROM_FILE} #{TO_FILE}", @s00.to_s)
  end

  def test_equal
    assert_equal(false, @s00 == @s01)
    assert_equal(false, @s01 == @s00)
    assert_equal(false,
                 @s00 == FileRenamer::Manipulation::Mv.new(FROM_FILE, TO_FILE))
    assert_equal(true ,
                 @s00 == FileRenamer::Manipulation::Lns.new(FROM_FILE, TO_FILE))
    assert_equal(true , 
                 @s01 == FileRenamer::Manipulation::Lns.new(FROM_DIR, TO_DIR))
  end

end

