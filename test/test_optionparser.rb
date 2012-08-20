#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "filerenamer/optionparser.rb"

class TC_OptionParser < Test::Unit::TestCase
  #def setup
  # @frop00 = FileRenamerOptionParser.new
  #end

  def test_sanity_check
    frop01 = FileRenamer::OptionParser.new
    ary = %w(-y --copy)
    frop01.parse(ary)
    assert_equal( { :yes => true, :copy => true }, frop01.options)

    # このクラスではオプションの整合性チェックは行わない。
    frop01 = FileRenamer::OptionParser.new
    ary = %w(-y -n)
    frop01.parse(ary)
    assert_equal( { :yes => true, :no => true }, frop01.options)

    frop01 = FileRenamer::OptionParser.new
    ary = %w(-y -n -c -m -h -s -q)
    frop01.parse(ary)
    corrects = {
      :yes => true,
      :no => true,
      :copy => true,
      :move => true,
      :hardlink => true,
      :symlink => true,
      :quiet => true
    }
    assert_equal(corrects, frop01.options)

    frop01 = FileRenamer::OptionParser.new
    ary = %w(--yes --no --copy --move --hardlink --symlink --quiet)
    frop01.parse(ary)
    corrects = {
      :yes => true,
      :no => true,
      :copy => true,
      :move => true,
      :hardlink => true,
      :symlink => true,
      :quiet => true
    }
    assert_equal(corrects, frop01.options)
  end
end

