#! /usr/bin/env ruby
# coding: utf-8

require "helper"
require "fileutils"
require "stringio"
#require "test/unit"
#require "pkg/klass.rb"

class TC_Mkdirp < Test::Unit::TestCase
  ORIG_DIR = "test/manipulation/mkdirp/orig"
  TMP_DIR = "test/manipulation/mkdirp/tmp"
  DIR = "#{TMP_DIR}/00"

  def setup
    FileUtils.cp_r(ORIG_DIR, TMP_DIR)
    @m00 = FileRenamer::Manipulation::Mkdirp.new(DIR)
  end

  def teardown
    FileUtils.rm_rf(TMP_DIR) if File.exist? TMP_DIR
  end

  def test_initialize
    assert_raise(FileRenamer::Manipulation::Mkdirp::ArgumentError){
      FileRenamer::Manipulation::Mkdirp.new
    }
    assert_raise(FileRenamer::Manipulation::Mkdirp::ArgumentError){
      FileRenamer::Manipulation::Mkdirp.new("#{TMP_DIR}/00")
    }
    assert_raise(FileRenamer::Manipulation::Mkdirp::ArgumentError){
      FileRenamer::Manipulation::Mkdirp.new("#{TMP_DIR}/00",
                                        "#{TMP_DIR}/01",
                                        "#{TMP_DIR}/02")
    }
  end

  def test_vanishing_files
    assert_equal([], @m00.vanishing_files)

    assert_equal([], @m01.vanishing_files)
  end

  def test_appearing_files
    assert_equal([TO_FILE], @m00.appearing_files)

    assert_equal(
      [ "#{TO_DIR}", "#{TO_DIR}/01", "#{TO_DIR}/02" ],
      @m01.appearing_files
    )
  end

  def test_execute_with_io
    assert_equal(true , File.exist?(DIR))
    assert_equal(false, File.exist?(TO_FILE))
    io = StringIO.new
    @m00.execute(io)
    assert_equal(true , File.exist?(DIR))
    assert_equal(true , File.exist?(TO_FILE))

    assert_equal(true , File.exist?(FROM_DIR))
    assert_equal(true , File.exist?(FROM_DIR + "/01"))
    assert_equal(true , File.exist?(FROM_DIR + "/02"))
    assert_equal(false, File.exist?(TO_DIR))
    io = StringIO.new
    @m01.execute(io)
    assert_equal(true , File.exist?(FROM_DIR))
    assert_equal(true , File.exist?(FROM_DIR + "/01"))
    assert_equal(true , File.exist?(FROM_DIR + "/02"))
    assert_equal(true , File.exist?(TO_DIR))
    assert_equal(true , File.exist?(TO_DIR + "/01"))
    assert_equal(true , File.exist?(TO_DIR + "/02"))
  end

  def test_execute_without_io
    assert_equal(true , File.exist?(DIR))
    assert_equal(false, File.exist?(TO_FILE))
    @m00.execute
    assert_equal(true , File.exist?(DIR))
    assert_equal(true , File.exist?(TO_FILE))

    assert_equal(true , File.exist?(FROM_DIR))
    assert_equal(true , File.exist?(FROM_DIR + "/01"))
    assert_equal(true , File.exist?(FROM_DIR + "/02"))
    assert_equal(false, File.exist?(TO_DIR))
    @m01.execute
    assert_equal(true , File.exist?(FROM_DIR))
    assert_equal(true , File.exist?(FROM_DIR + "/01"))
    assert_equal(true , File.exist?(FROM_DIR + "/02"))
    assert_equal(true , File.exist?(TO_DIR))
    assert_equal(true , File.exist?(TO_DIR + "/01"))
    assert_equal(true , File.exist?(TO_DIR + "/02"))
  end

  def test_to_s
    assert_equal("mkdir -p #{DIR} #{TO_FILE}", @m00.to_s)
  end

end

