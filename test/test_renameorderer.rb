#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "helper"
#require "test/unit"
#require "pkg/klass.rb"

#pp "old ファイルが存在しなければ unable"
#pp "old に重複があれば、例外"


$DEBUG = false

class TC_RenameOrderer < Test::Unit::TestCase

  D01   = 'test/renameorderer/01'
  D012  = 'test/renameorderer/012'
  D0123 = 'test/renameorderer/0123'
  D02   = 'test/renameorderer/02'

  # independent
  def test_00
    ro = FileRenamer::RenameOrderer.new({ '0' => '1', '2' => '3'}, D02)
    assert_equal([ %w(0 1), %w(2 3)], ro.rename_processes)
    assert_equal([                   ], ro.unable_processes)
  end

  # dependent
  def test_01
    ro  = FileRenamer::RenameOrderer.new({ '0' => '1', '1' => '2'}, D01)
    assert_equal([ %w(1 2), %w(0 1)], ro.rename_processes)
    assert_equal([                   ], ro.unable_processes)
  end

  # dependent
  def test_02
    ro = FileRenamer::RenameOrderer.new({ '1' => '2', '0' => '1'}, D01)
    assert_equal([ %w(1 2), %w(0 1)], ro.rename_processes)
    assert_equal([], ro.unable_processes)
  end

  # dup target
  def test_03
    ro = FileRenamer::RenameOrderer.new({ '0' => '1', '2' => '1'}, D02)
    assert_equal([                   ], ro.rename_processes)
    assert_equal([ %w(0 1), %w(2 1)], ro.unable_processes)
  end

  # swap (circular when 2)
  def test_04
    ro = FileRenamer::RenameOrderer.new({'0' => '1', '1' => '0'}, D01)
    results = ro.rename_processes
    assert_equal(3, results.size)
    assert_equal('0', results[0][0])
    assert_equal('1', results[1][0])
    assert(/^test/ =~ results[2][0])
    assert(/^test/ =~ results[0][1])
    assert_equal('0', results[1][1])
    assert_equal('1', results[2][1])

    assert_equal([], ro.unable_processes)
  end

  # circular
  def test_05
    ro = FileRenamer::RenameOrderer.new({ '0' => '1', '1' => '2', '2' => '0'}, D012)
    results = ro.rename_processes
    assert_equal(4, results.size)
    assert_equal('0', results[0][0])
    assert_equal('2', results[1][0])
    assert_equal('1', results[2][0])
    assert(/^test/ =~ results[3][0])
    assert(/^test/ =~ results[0][1])
    assert_equal('0', results[1][1])
    assert_equal('2', results[2][1])
    assert_equal('1', results[3][1])

    assert_equal([], ro.unable_processes)
  end

  # circular adding depend
  def test_06
    ro = FileRenamer::RenameOrderer.new({ '0' => '1', '1' => '2', '2' => '0', '3' => '0'}, D0123)
    assert_equal([                                    ], ro.rename_processes)
    assert_equal([ %w(0 1), %w(1 2), %w(2 0), %w(3 0)], ro.unable_processes)
  end

  # dup target and independent
  def test_07
    ro = FileRenamer::RenameOrderer.new({ '0' => '3', '1' => '3', '2' => '4'}, D012)
    assert_equal([ %w(2 4)], ro.rename_processes)
    assert_equal([ %w(0 3), %w(1 3)], ro.unable_processes)
  end

  # not exist
  def test_08
    #$DEBUG = true
    ro = FileRenamer::RenameOrderer.new({'2' => '3'}, D01)
    assert_equal([], ro.rename_processes)
    assert_equal([ %w(2 3) ], ro.unable_processes)
  end

  # same name
  def test_09
    ro = FileRenamer::RenameOrderer.new({ '0' => '0', '1' => '2'}, D01)
    assert_equal([ %w(1 2)], ro.rename_processes)
    assert_equal([ %w(0 0)], ro.unable_processes)
  end

  #undef test_00
  #undef test_01
  #undef test_02
  #undef test_03
  #undef test_04
  ##undef test_05
  #undef test_06
  #undef test_07
  #undef test_08
  #undef test_09

end

