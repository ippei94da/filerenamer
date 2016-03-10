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
    public :check_new_names
    public :ask_yes?
    public :run
    public :make_new_names
    public :paths
    attr_reader :options
  end
end

class TC_Commander < Test::Unit::TestCase
  EXIST_FILE = "test/filerenamer/dummy.txt"

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
    io = StringIO.new
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
      "Unable files:\n" +
      "  cp -r #{A_0} #{A_0}\n" +
      "  cp -r #{A_1} #{A_0}\n" +
      "\n" +
      "Done. No executable files.\n"
    t = str
    assert_equal(correct[0], t[0])
    assert_equal(correct[1], t[1])
    assert_equal(correct[2], t[2])
    assert_equal(correct[3], t[3])
    assert_equal(correct[4], t[4])
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
    #pp [A_0, A_1]; exit
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
    files = {
      "alice.txt"   => EXIST_FILE,
      "bcdefgh.txt" => EXIST_FILE,
      "charly.txt"  => "C.txt",
      "david.txt"   => "D.txt",
      EXIST_FILE    => EXIST_FILE,
      "eva.txt"     => "alice.txt",
      "f.txt"       => "f.txt",
      "g.txt"       => nil,
    }
    ok_list, ng_list = @fr00.check_new_names(files)
    assert_equal(
      { "charly.txt"  => "C.txt",
        "david.txt"   => "D.txt",
      },
      ok_list
    )
    assert_equal(
      { "alice.txt"   => EXIST_FILE,
        "bcdefgh.txt" => EXIST_FILE,
        EXIST_FILE    => EXIST_FILE,
        "eva.txt"     => "alice.txt",
      },
      ng_list
    )

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

  def test_run
    # ディレクトリ消去が必要な場合
    FileUtils.rm("tmp1/dir/a1.txt") if FileTest.exist?("tmp1/dir/a1.txt")
    FileUtils.rm("tmp2/dir/a1.txt") if FileTest.exist?("tmp2/dir/a1.txt")
    FileUtils.rmdir("tmp1/dir") if FileTest.exist?("tmp1")
    FileUtils.rmdir("tmp2/dir") if FileTest.exist?("tmp2")
    FileUtils.rmdir("tmp1") if FileTest.exist?("tmp1")
    FileUtils.rmdir("tmp2") if FileTest.exist?("tmp2")
    #
    FileUtils.mkdir("tmp1")
    FileUtils.mkdir("tmp1/dir")
    FileUtils.cp(A_0, "tmp1/dir/a1.txt")
    #
    assert_equal(false, FileTest.exist?("tmp2/dir/a2")) #実行前に変換先が存在しないことを確認。
    #@fr00.run("tmp1/dir/a1.txt", "tmp2/dir/a1.txt")
    str = capture_stdout{ @fr00.run("tmp1/dir/a1.txt", "tmp2/dir/a1.txt") }
    t = str
    correct = "  make directory: tmp2\n" +
      "  make directory: tmp2/dir\n" +
      "  mv tmp1/dir/a1.txt tmp2/dir/a1.txt\n" +
      "  remove directory: tmp1/dir\n" +
      "  remove directory: tmp1\n"
    assert_equal(correct, t)
    #
    assert_equal(false, FileTest.exist?("tmp1"))
    assert_equal(true , FileTest.exist?("tmp2/dir/a1.txt")) #実行後に変換先が存在することを確認。
    #
    # あとかたづけ
    FileUtils.rmdir("tmp1/dir")
    FileUtils.rmdir("tmp1")
    FileUtils.rm("tmp2/dir/a1.txt")
    FileUtils.rmdir("tmp2/dir")
    FileUtils.rmdir("tmp2")
  end

  def test_paths
    assert_equal(["foo", "foo/bar"], @fr00.paths("foo/bar/baz.txt"))
    assert_equal([], @fr00.paths("baz.txt"))
    assert_equal(["/foo", "/foo/bar"], @fr00.paths("/foo/bar/baz.txt"))
  end
end

