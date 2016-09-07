#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "helper"
#require "test/unit"
#require "pkg/klass.rb"

class TC_RenameOrderer < Test::Unit::TestCase
  def setup
    @ro0 = RenameOrderer.new([ %w(00 01), %w(10 11), ]) # independent
    @ro1 = RenameOrderer.new([ %w(01 02), %w(00 01), ]) # dependent
    @ro2 = RenameOrderer.new([ %w(00 01), %w(10 01), ]) # dup target
    @ro3 = RenameOrderer.new([ %w(00 01), %w(01 00), ]) # swap (circular when 2)
    @ro4 = RenameOrderer.new([ %w(00 01), %w(01 02), %w(02 00) ]) # circular
    @ro5 = RenameOrderer.new([ %w(00 01), %w(01 02), %w(02 00), %w(03 00) ]) # circular adding depend
    @ro6 = RenameOrderer.new([ %w(00 01), %w(10 01), %w(02 03) ]) # dup target and independent

  end

  def test_rename_order
    assert_equal([ %w(00 01), %w(10 11), ], @ro0.rename_order)
    assert_equal([ %w(01 02), %w(00 01), ], @ro1.rename_order)
    assert_equal([                       ], @ro2.rename_order)
    assert_equal([ %w(00 tmp), %w(01 00), %w(tmp 01)], @ro3.rename_order)
    assert_equal([ %w(00 tmp), %w(02 00), %w(01 02), %w(00 01), %w(tmp 02)], @ro4.rename_order)
    assert_equal([                       ], @ro5.rename_order)
    assert_equal([                       ], @ro6.rename_order)
  end

  def test_unable_list
    assert_equal([                       ], @ro0.unable_list)
    assert_equal([                       ], @ro1.unable_list)
    assert_equal([ %w(00 01), %w(10 01), ], @ro2.unable_list)
    assert_equal([                       ], @ro3.unable_list)
    assert_equal([                       ], @ro4.unable_list)
    assert_equal([ %w(00 01), %w(01 02), %w(02 00), %w(03 00) ], @ro5.unable_list)
    assert_equal([ %w(00 01), %w(10 01), %w(02 03) ], @ro6.unable_list)
  end

end

