#! /usr/bin/env ruby
# coding: utf-8

require "helper"
#require "test/unit"
#require "pkg/klass.rb"

class FileRenamer::ManipulationQueue
  attr_reader :manipulations
end

class TC_ManipulationQueue < Test::Unit::TestCase

  ORIG_DIR = "test/manipulationqueue/orig"
  TMP_DIR = "test/manipulationqueue/tmp"

  def setup
    FileUtils.cp_r(ORIG_DIR, TMP_DIR)
    @ms00 = FileRenamer::ManipulationQueue.new
  end

  def teardown
    FileUtils.rm_rf(TMP_DIR) if File.exist? TMP_DIR
  end

  def test_enqueue_cp
    @ms00.enqueue_cp(TMP_DIR + "/00", TMP_DIR + "/01")
    assert_equal(
      FileRenamer::Manipulation::Cp.new(TMP_DIR + "/00", TMP_DIR + "/01"),
      @ms00.manipulations[0]
    )
  end

  def test_enqueue_mv
    @ms00.enqueue_mv(TMP_DIR + "/00", TMP_DIR + "/01")
    assert_equal(
      FileRenamer::Manipulation::Mv.new(TMP_DIR + "/00", TMP_DIR + "/01"),
      @ms00.manipulations[0]
    )
  end

  def test_enqueue_ln_s
    @ms00.enqueue_ln_s(TMP_DIR + "/00", TMP_DIR + "/01")
    assert_equal(
      FileRenamer::Manipulation::Lns.new(TMP_DIR + "/00", TMP_DIR + "/01"),
      @ms00.manipulations[0]
    )
  end

  def test_enqueue_ln
    @ms00.enqueue_ln(TMP_DIR + "/00", TMP_DIR + "/01")
    assert_equal(
      FileRenamer::Manipulation::Ln.new(TMP_DIR + "/00", TMP_DIR + "/01"),
      @ms00.manipulations[0]
    )
  end

  #def test_enqueue_rm
  #  @ms00.enqueue_rm(TMP_DIR + "/00")
  #  assert_equal(
  #    FileRenamer::Manipulation::Rm.new(TMP_DIR + "/00"),
  #    @ms00.manipulations[0]
  #  )
  #end

  def test_simulate
    TODO
  end

  def test_execute
    TODO
  end

  def test_ask
    TODO
  end

end

