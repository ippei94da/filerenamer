#! /usr/bin/env ruby
# coding: utf-8

require "helper"
require "fileutils"
require "stringio"
#require "test/unit"
#require "pkg/klass.rb"

class TC_Mv < Test::Unit::TestCase
  ORIG_DIR = "test/manipulation/mv/orig"
  TMP_DIR = "test/manipulation/mv/tmp"
  FROM_FILE = "#{TMP_DIR}/00"
  TO_FILE ="#{TMP_DIR}/01"

  def setup
    FileUtils.cp_r(ORIG_DIR, TMP_DIR)
    @m00 = FileRenamer::Manipulation::Mv.new(FROM_FILE, TO_FILE)
  end

  def teardown
    FileUtils.rm_rf(TMP_DIR) if File.exist? TMP_DIR
  end

  def test_initialize(* files)
    assert_raise(FileRenamer::Manipulation::Mv::ArgumentError){
      FileRenamer::Manipulation::Mv.new
    }
    assert_raise(FileRenamer::Manipulation::Mv::ArgumentError){
      FileRenamer::Manipulation::Mv.new("#{TMP_DIR}/00")
    }
    assert_raise(FileRenamer::Manipulation::Mv::ArgumentError){
      FileRenamer::Manipulation::Mv.new("#{TMP_DIR}/00",
                                        "#{TMP_DIR}/01",
                                        "#{TMP_DIR}/02")
    }
  end

  def test_vanishing_file
    assert_equal(FROM_FILE, @m00.vanishing_file)
  end

  def test_appering_file
    assert_equal(TO_FILE, @m00.appering_file)
  end

  def test_execute_with_io
    assert_equal(true , File.exist?(FROM_FILE))
    assert_equal(false, File.exist?(TO_FILE))
    io = StringIO.new
    @m00.execute(io)
    assert_equal(false, File.exist?(FROM_FILE))
    assert_equal(true , File.exist?(TO_FILE))
  end

  def test_execute_without_io
    assert_equal(true , File.exist?(FROM_FILE))
    assert_equal(false, File.exist?(TO_FILE))
    @m00.execute
    assert_equal(false, File.exist?(FROM_FILE))
    assert_equal(true , File.exist?(TO_FILE))
  end

  def test_to_s
    assert_equal("mv #{FROM_FILE} #{TO_FILE})
  end

end

