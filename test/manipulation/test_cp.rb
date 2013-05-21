#! /usr/bin/env ruby
# coding: utf-8

require "helper"
require "fileutils"
require "stringio"
#require "test/unit"
#require "pkg/klass.rb"

class TC_Cp < Test::Unit::TestCase
  ORIG_DIR = "test/manipulation/cp/orig"
  TMP_DIR = "test/manipulation/cp/tmp"
  FROM_FILE = "#{TMP_DIR}/00"
  TO_FILE ="#{TMP_DIR}/01"

  FROM_DIR = "#{TMP_DIR}/dir00"
  TO_DIR ="#{TMP_DIR}/dir01"

  def setup
    FileUtils.cp_r(ORIG_DIR, TMP_DIR)
    @c00 = FileRenamer::Manipulation::Cp.new(FROM_FILE, TO_FILE)

    @c01 = FileRenamer::Manipulation::Cp.new(FROM_DIR, TO_DIR)
  end

  def teardown
    FileUtils.rm_rf(TMP_DIR) if File.exist? TMP_DIR
  end

  def test_initialize
    assert_raise(FileRenamer::Manipulation::Cp::ArgumentError){
      FileRenamer::Manipulation::Cp.new
    }
    assert_raise(FileRenamer::Manipulation::Cp::ArgumentError){
      FileRenamer::Manipulation::Cp.new("#{TMP_DIR}/00")
    }
    assert_raise(FileRenamer::Manipulation::Cp::ArgumentError){
      FileRenamer::Manipulation::Cp.new("#{TMP_DIR}/00",
                                        "#{TMP_DIR}/01",
                                        "#{TMP_DIR}/02")
    }
  end

  def test_vanishing_files
    assert_equal([], @c00.vanishing_files)

    assert_equal([], @c01.vanishing_files)
  end

  def test_appearing_files
    assert_equal([TO_FILE], @c00.appearing_files)

    assert_equal(
      [ "#{TO_DIR}", "#{TO_DIR}/01", "#{TO_DIR}/02" ],
      @c01.appearing_files
    )
  end

  def test_execute_with_io
    assert_equal(true , File.exist?(FROM_FILE))
    assert_equal(false, File.exist?(TO_FILE))
    io = StringIO.new
    @c00.execute(io)
    assert_equal(true , File.exist?(FROM_FILE))
    assert_equal(true , File.exist?(TO_FILE))

    assert_equal(true , File.exist?(FROM_DIR))
    assert_equal(true , File.exist?(FROM_DIR + "/01"))
    assert_equal(true , File.exist?(FROM_DIR + "/02"))
    assert_equal(false, File.exist?(TO_DIR))
    io = StringIO.new
    @c01.execute(io)
    assert_equal(true , File.exist?(FROM_DIR))
    assert_equal(true , File.exist?(FROM_DIR + "/01"))
    assert_equal(true , File.exist?(FROM_DIR + "/02"))
    assert_equal(true , File.exist?(TO_DIR))
    assert_equal(true , File.exist?(TO_DIR + "/01"))
    assert_equal(true , File.exist?(TO_DIR + "/02"))
  end

  def test_execute_without_io
    assert_equal(true , File.exist?(FROM_FILE))
    assert_equal(false, File.exist?(TO_FILE))
    @c00.execute
    assert_equal(true , File.exist?(FROM_FILE))
    assert_equal(true , File.exist?(TO_FILE))

    assert_equal(true , File.exist?(FROM_DIR))
    assert_equal(true , File.exist?(FROM_DIR + "/01"))
    assert_equal(true , File.exist?(FROM_DIR + "/02"))
    assert_equal(false, File.exist?(TO_DIR))
    @c01.execute
    assert_equal(true , File.exist?(FROM_DIR))
    assert_equal(true , File.exist?(FROM_DIR + "/01"))
    assert_equal(true , File.exist?(FROM_DIR + "/02"))
    assert_equal(true , File.exist?(TO_DIR))
    assert_equal(true , File.exist?(TO_DIR + "/01"))
    assert_equal(true , File.exist?(TO_DIR + "/02"))
  end

  def test_to_s
    assert_equal("cp -r #{FROM_FILE} #{TO_FILE}", @c00.to_s)
  end

  def test_equal
    assert_equal(false, @c00 == @c01)
    assert_equal(false, @c01 == @c00)
    assert_equal(false,
                 @c00 == FileRenamer::Manipulation::Mv.new(FROM_FILE, TO_FILE))
    assert_equal(true ,
                 @c00 == FileRenamer::Manipulation::Cp.new(FROM_FILE, TO_FILE))
    assert_equal(true , 
                 @c01 == FileRenamer::Manipulation::Cp.new(FROM_DIR, TO_DIR))
  end

end

