#! /usr/bin/env ruby
# coding: utf-8

require 'helper'

require "pp"
require "test/unit"
require "filerenamer/commander.rb"
require "stringio"
require "rubygems"
gem "capture_stdout"
require "capture_stdout"

module FileRenamer
  class Commander
    #public :check_new_names
    public :ask_yes?
    public :make_new_names
    public :paths
    public :transplant
    public :rmdir_p
    public :convert
    attr_reader :options
  end
end

class TC_Commander < Test::Unit::TestCase

  A_0 = "test/filerenamer/a0.txt"
  A_1 = "test/filerenamer/a1.txt"

  def setup
    options = {}
    @fr00 = FileRenamer::Commander.new(options, [])

    options = {:copy => true, :yes => true}
    @fr01 = FileRenamer::Commander.new(options, [])
  end

  def test_self_files
    #pp FileRenamer::Commander.files([])
    #pp FileRenamer::Commander.files(['a', 'b'])
  end

  def test_initialize
    # yes and no
    options = {
      :yes => true,
      :no => true,
    }
    assert_raise(FileRenamer::Commander::OptionError){ FileRenamer::Commander.new(options, []) }

    # ファイル操作モードがどれか1つのみ true なら OK。
    options = { :copy => true, }
    assert_nothing_raised{ FileRenamer::Commander.new(options, []) }

    options = { :move => true, }
    assert_nothing_raised{ FileRenamer::Commander.new(options, []) }

    options = { :hardlink => true, }
    assert_nothing_raised{ FileRenamer::Commander.new(options, []) }

    options = { :symlink => true, }
    assert_nothing_raised{ FileRenamer::Commander.new(options, []) }

    # ファイル操作モードが空でも OK で、その場合は :move が true として扱われる。
    options = { }
    fr00 = FileRenamer::Commander.new(options, [])
    assert_equal( {:move => true}, fr00.options )

    # ファイル操作モードで矛盾する2つ以上が true なら例外。
    options = {
      :move => true,
      :copy => true,
    }
    assert_raise(FileRenamer::Commander::OptionError){ FileRenamer::Commander.new(options, []) }

    options = {
      :move => true,
      :hardlink => true,
    }
    assert_raise(FileRenamer::Commander::OptionError){ FileRenamer::Commander.new(options, []) }

    options = {
      :move => true,
      :symlink => true,
    }
    assert_raise(FileRenamer::Commander::OptionError){ FileRenamer::Commander.new(options, []) }

    # :quiet が立てられれば、自動的に :yes も true になる。
    options = {:quiet => true}
    fr00 = FileRenamer::Commander.new(options, [])
    assert_equal( {:quiet => true, :yes => true, :move => true}, fr00.options )

    # :quiet が立てられれば、:yes が明示的に立っていても問題なし。
    options = {:quiet => true, :yes => true}
    fr00 = FileRenamer::Commander.new(options, [])
    assert_equal( {:quiet => true, :yes => true, :move => true}, fr00.options )

    # :quiet が立てられれば、:no が立っていれば例外。
    options = {:quiet => true, :no => true}
    assert_raise(FileRenamer::Commander::OptionError){ FileRenamer::Commander.new(options, []) }
  end

  def test_execute
    # :yes
    # pre-process
    FileUtils.rm(A_1) if FileTest.exist?(A_1)
    #
    options = {:copy => true, :yes => true}
    fr01 = FileRenamer::Commander.new(options, [A_0])
    str = capture_stdout{fr01.execute{ A_1 }}
    assert_equal(true, FileTest.exist?(A_0))
    assert_equal(true, FileTest.exist?(A_1))
    FileUtils.rm(A_1)
    correct = 
      "Enable files:\n" +
      "  cp -r #{A_0} #{A_1}\n" +
      "Execute? yes\n" +
      "  cp -r #{A_0} #{A_1}\n"
    t = str
    assert_equal(correct[0], t[0])
    assert_equal(correct[1], t[1])
    assert_equal(correct[2], t[2])
    assert_equal(correct[3], t[3])
    assert_equal(correct[4], t[4])

    # :no
    FileUtils.rm(A_1) if FileTest.exist?(A_1)
    #
    options = {:copy => true, :no => true}
    fr01 = FileRenamer::Commander.new(options, [A_0])
    str = capture_stdout{ fr01.execute{ A_1 }}
    assert_equal(true , FileTest.exist?(A_0))
    assert_equal(false, FileTest.exist?(A_1))
    #
    correct = 
      "Enable files:\n" +
      "  cp -r #{A_0} #{A_1}\n" +
      "Execute? no\n"
    t = str
    assert_equal(correct[0], t[0])
    assert_equal(correct[1], t[1])
    assert_equal(correct[2], t[2])

    #:quiet
    FileUtils.rm(A_1) if FileTest.exist?(A_1)
    #
    options = {:copy => true, :quiet => true}
    fr01 = FileRenamer::Commander.new(options, [A_0])
    str = capture_stdout{fr01.execute{ A_1 }}
    assert_equal(true, FileTest.exist?(A_0))
    assert_equal(true, FileTest.exist?(A_1))
    FileUtils.rm(A_1)
    #
    assert_equal( "", str)

    #ask
    FileUtils.rm(A_1) if FileTest.exist?(A_1)
    $stdin = StringIO.new
    $stdin.puts "yes"
    $stdin.rewind
    output = StringIO.new
    #
    options = {:copy => true}
    fr01 = FileRenamer::Commander.new(options, [A_0])
    str = capture_stdout{fr01.execute{ A_1 }}
    assert_equal(true, FileTest.exist?(A_0))
    assert_equal(true, FileTest.exist?(A_1))
    FileUtils.rm(A_1)
    #
    correct = 
        "Enable files:\n" +
        "  cp -r #{A_0} #{A_1}\n" +
        "Execute?\n" +
        "  cp -r #{A_0} #{A_1}\n"
    t = str
    assert_equal(correct[0], t[0])
    assert_equal(correct[1], t[1])
    assert_equal(correct[2], t[2])
    assert_equal(correct[3], t[3])

    $stdin = STDIN

    #ask
    #NG ファイルが存在するときの表示
    FileUtils.rm(A_1) if FileTest.exist?(A_1)
    $stdin = StringIO.new
    $stdin.puts "yes"
    $stdin.rewind
    output = StringIO.new
    #
    options = {:copy => true}
    fr01 = FileRenamer::Commander.new(options, [A_1])
    str = capture_stdout{fr01.execute{ A_0 }}
    assert_equal(true , FileTest.exist?(A_0))
    assert_equal(false, FileTest.exist?(A_1))
    #
    correct = 
      #"Unable files:\n" +
      #"  cp -r #{A_0} #{A_0}\n" +
      #"  cp -r #{A_1} #{A_0}\n" +
      #"\n" +
      "Done. No executable files.\n"
    t = str
    assert_equal(correct[0], t[0])
    #assert_equal(correct[1], t[1])
    #assert_equal(correct[2], t[2])
    #assert_equal(correct[3], t[3])
    #assert_equal(correct[4], t[4])
    $stdin = STDIN

    ## ファイルリストを与えないときはカレントディレクトリの全ファイルが対象。
    #FileUtils.rm(A_1) if FileTest.exist?(A_1)
    ##
    #options = {:copy => true, :no => true}
    #fr01 = FileRenamer::Commander.new(options)
    #str = capture_stdout{ fr01.execute([]){|name| name + ".00"}}
    ##
    #correct = 
    #  "Enable files:\n" +
    #  "  cp -r Gemfile      Gemfile.00\n" +
    #  "  cp -r Gemfile.lock Gemfile.lock.00\n" +
    #  "  cp -r LICENSE.txt  LICENSE.txt.00\n" +
    #  "  cp -r README.rdoc  README.rdoc.00\n" +
    #  "  cp -r Rakefile     Rakefile.00\n" +
    #  "  cp -r VERSION      VERSION.00\n" +
    #  "  cp -r lib          lib.00\n" +
    #  "  cp -r test         test.00\n" +
    #  "Execute? no\n"
    #assert_equal( correct, str)
  end

  def test_make_new_names
    options = {}
    fr00 = FileRenamer::Commander.new(options, [A_0, A_1])
    assert_equal(
      {
        A_0 => A_0 + "00",
        A_1 => A_1 + "00",
      },
      fr00.make_new_names{ |old|
        old.sub(/$/, "00")
      }
    )
  end

  def test_check_new_names
    #exist_file = "test/filerenamer/dummy.txt"
    #files = {
    #  "alice.txt"   => exist_file,
    #  "bcdefgh.txt" => exist_file,
    #  "charly.txt"  => "C.txt",
    #  "david.txt"   => "D.txt",
    #  exist_file    => exist_file,
    #  "eva.txt"     => "alice.txt",
    #  "f.txt"       => "f.txt",
    #  "g.txt"       => nil,
    #}
    #ok_list, ng_list = @fr00.check_new_names(files)
    #assert_equal(
    #  { "charly.txt"  => "C.txt",
    #    "david.txt"   => "D.txt",
    #  },
    #  ok_list
    #)
    #assert_equal(
    #  { "alice.txt"   => exist_file,
    #    "bcdefgh.txt" => exist_file,
    #    exist_file    => exist_file,
    #    "eva.txt"     => "alice.txt",
    #  },
    #  ng_list
    #)

    #a_file = "test/commander/a.file" #exist
    #b_file = "test/commander/b.file" #exist
    #c_file = "test/commander/c.file" #not exist
    #d_file = "test/commander/d.file" #not exist

    ## 変化なし
    #files = { "a.file" => 'a.file', "b.file" => 'b.file', }
    #ok_list, ng_list = @fr00.check_new_names(files)
    #assert_equal( {}, ok_list)
    #assert_equal( {}, ng_list)

    ## 相互入れ替え
    #files = { "a.file" => 'b.file', "b.file" => 'a.file', }
    #ok_list, ng_list = @fr00.check_new_names(files)
    #assert_equal( files, ok_list)
    #assert_equal( {}   , ng_list)

    ## 宛先が重複
    #files = { "a.file" => 'c.file', "b.file" => 'c.file', }
    #ok_list, ng_list = @fr00.check_new_names(files)
    #assert_equal( {}   , ok_list)
    #assert_equal( files, ng_list)

    ## 玉突き
    #files = { "a.file" => 'b.file', "b.file" => 'c.file', }
    #ok_list, ng_list = @fr00.check_new_names(files)
    #assert_equal( files, ok_list)
    #assert_equal( {}   , ng_list)
  end

  def test_ask_yes?
    $stdin = StringIO.new
    $stdin.puts "Y"
    $stdin.rewind
    result = Object.new
    str = capture_stdout{ result = @fr00.ask_yes?}
    assert_equal(true , result)
    assert_equal("Execute?\n" , str)

    $stdin = StringIO.new
    $stdin.puts "y"
    $stdin.rewind
    io = capture_stdout{ result = @fr00.ask_yes?}
    assert_equal(true , result)

    $stdin = StringIO.new
    $stdin.puts "Yreqwj"
    $stdin.rewind
    io = capture_stdout{ result = @fr00.ask_yes?}
    assert_equal(true , result)

    $stdin = StringIO.new
    $stdin.puts "yrqewv"
    $stdin.rewind
    io = capture_stdout{ result = @fr00.ask_yes?}
    assert_equal(true , result)

    $stdin = StringIO.new
    $stdin.puts "n"
    $stdin.rewind
    io = capture_stdout{ result = @fr00.ask_yes?}
    assert_equal(false, result)

    $stdin = StringIO.new
    $stdin.puts "N"
    $stdin.rewind
    io = capture_stdout{ result = @fr00.ask_yes?}
    assert_equal(false, result)

    $stdin = StringIO.new
    $stdin.puts ""
    $stdin.rewind
    io = capture_stdout{ result = @fr00.ask_yes?}
    assert_equal(false, result)
  end

  def test_convert
    root_dir = 'test/commander/convert'
    FileUtils.rm_rf root_dir

    a0 = "#{root_dir}/a0.file"
    FileUtils.mkdir_p(File.dirname a0)
    File.open(a0, 'w').close

    a1 = "#{root_dir}/a1.file"
    FileUtils.mkdir_p(File.dirname a1)
    File.open(a1, 'w').close

    assert_equal(true , FileTest.exist?(a0))
    @fr00.convert({a0 => a1})
    assert_equal(false, FileTest.exist?(a0))
    assert_equal(true , FileTest.exist?(a1))

    FileUtils.rm_rf root_dir
  end

  def test_transplant
    src_root_dir = "test/commander/transplant"
    src_dir   = "#{src_root_dir}/a/b/c"
    src_file1 = "#{src_dir}/1.file"
    src_file2 = "#{src_dir}/2.file"
    tgt_dir = "test/commander/transplant/d"
    tgt_file1 = "#{tgt_dir}/1.file"
    tgt_file2 = "#{tgt_dir}/2.file"

    FileUtils.rm_rf([src_root_dir, tgt_dir])

    FileUtils.mkdir_p src_dir
    File.open(src_file1, 'w').close
    File.open(src_file2, 'w').close


    @fr00.transplant(src_file1, tgt_file1)
    assert_equal(false, FileTest.exist?(src_file1))
    assert_equal(true , FileTest.exist?(src_file2))
    assert_equal(true , FileTest.exist?(tgt_file1))
    assert_equal(false, FileTest.exist?(tgt_file2))

    @fr00.transplant(src_file2, tgt_file2)
    assert_equal(false, FileTest.exist?(src_file1))
    assert_equal(false, FileTest.exist?(src_file2))
    assert_equal(true , FileTest.exist?(tgt_file1))
    assert_equal(true , FileTest.exist?(tgt_file2))
    assert_equal(false, FileTest.exist?(src_root_dir + '/a'))

    FileUtils.rm_rf(src_root_dir)
  end

  def test_paths
    assert_equal(["foo", "foo/bar"], @fr00.paths("foo/bar/baz.txt"))
    assert_equal([], @fr00.paths("baz.txt"))
    assert_equal(["/foo", "/foo/bar"], @fr00.paths("/foo/bar/baz.txt"))
  end

  def test_rmdir_p
    root_dir = 'test/commander/rmdir_p'
    dir = root_dir + '/a/b/c'
    FileUtils.rm_rf dir
    FileUtils.mkdir_p dir
    file = dir + '/file'
    File.open(file, 'w').close

    @fr00.rmdir_p(dir)
    assert_equal(true, (FileTest.directory? dir))

    FileUtils.rm(file)
    @fr00.rmdir_p(dir)
    assert_equal(false, (FileTest.directory? root_dir))

    #teardown
    FileUtils.rm_rf dir
  end
end

