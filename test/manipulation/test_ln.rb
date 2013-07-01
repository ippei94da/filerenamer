#! /usr/bin/env ruby
# coding: utf-8

require "helper"
require "fileutils"
require "stringio"
#require "test/unit"
#require "pkg/klass.rb"

class TC_Ln < Test::Unit::TestCase
  ORIG_DIR = "test/manipulation/ln/orig"
  TMP_DIR = "test/manipulation/ln/tmp"
  FROM_FILE = "#{TMP_DIR}/00"
  TO_FILE ="#{TMP_DIR}/01"

  FROM_DIR = "#{TMP_DIR}/dir00"
  TO_DIR ="#{TMP_DIR}/dir01"

  def setup
    FileUtils.cp_r(ORIG_DIR, TMP_DIR)
    @l00 = FileRenamer::Manipulation::Ln.new(FROM_FILE, TO_FILE)
  end

  def teardown
    FileUtils.rm_rf(TMP_DIR) if File.exist? TMP_DIR
  end

  def test_initialize
    assert_raise(FileRenamer::Manipulation::Ln::ArgumentError){
      FileRenamer::Manipulation::Ln.new
    }
    assert_raise(FileRenamer::Manipulation::Ln::ArgumentError){
      FileRenamer::Manipulation::Ln.new("#{TMP_DIR}/00")
    }
    assert_raise(FileRenamer::Manipulation::Ln::ArgumentError){
      FileRenamer::Manipulation::Ln.new("#{TMP_DIR}/00",
                                        "#{TMP_DIR}/01",
                                        "#{TMP_DIR}/02")
    }
  end

  def test_vanishing_files
    assert_equal([], @l00.vanishing_files)
  end

  def test_appearing_files
    assert_equal([TO_FILE], @l00.appearing_files)
  end

  def test_execute_with_io
    assert_equal(true , File.exist?(FROM_FILE))
    assert_equal(false, File.exist?(TO_FILE))
    assert_equal(1 , File::Stat.new(FROM_FILE).nlink)
    io = StringIO.new
    @l00.execute(io)
    assert_equal(true , File.exist?(FROM_FILE))
    assert_equal(true , File.exist?(TO_FILE))
    assert_equal(2 , File::Stat.new(FROM_FILE).nlink)

  end

  def test_execute_without_io
    assert_equal(true , File.exist?(FROM_FILE))
    assert_equal(false, File.exist?(TO_FILE))
    @l00.execute
    assert_equal(true , File.exist?(FROM_FILE))
    assert_equal(true , File.exist?(TO_FILE))

  end

  def test_to_s
    assert_equal("ln #{FROM_FILE} #{TO_FILE}", @l00.to_s)
  end

  def test_equal
    assert_equal(false, @l00 == @l01)
    assert_equal(false, @l01 == @l00)
    assert_equal(false,
                 @l00 == FileRenamer::Manipulation::Mv.new(FROM_FILE, TO_FILE))
    assert_equal(true ,
                 @l00 == FileRenamer::Manipulation::Ln.new(FROM_FILE, TO_FILE))
  end

end
