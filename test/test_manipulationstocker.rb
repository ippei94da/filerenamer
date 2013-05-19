#! /usr/bin/env ruby
# coding: utf-8

require "helper"
#require "test/unit"
#require "pkg/klass.rb"

class TC_ManipulationStocker < Test::Unit::TestCase
  def setup
    @ms00 = ManipulationStocker.new
  end

  def test_add
    @ms00.add
  end

end

