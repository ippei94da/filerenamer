#! /usr/bin/env ruby
# coding: utf-8

#gem "builtinextension"
require "filerenamer/optionparser.rb"
require "fileutils"
require "optparse"
require "rubygems"
require "string/escapezsh.rb"
require "string/width.rb"
require 'tmpdir'
require 'pathname'

# ファイル群の名前変更を一括して行うためのクラス。
# 他のアプリケーションからも使えるけれど、
# 基本的にはコマンドライン関係の取り扱いを全部まとめてできるようにするもの。
# そのため、initialize で files を受け取ってしまい、
# execute の度に指定しなくても良いことにしている。
# execute の度に指定するようにすると、renpad のように対象全体を見てどうこうする
# コマンドで不便。
#
# MEMO:
# 一度 temporary directory にリネームして格納し、
# これをカレントディレクトリからのパスに移動する形を取ると、
# ディレクトリをまたぐリネームが非常に面倒なことになる。
# - 他のリネームに依存する場合に順序問題。
# - 相互依存のデッドロック
# gem などで提供される temporary directory は
# 基本的に 抜けたときに削除される筈なので、
# 途中まで変換してから interrupt されたときに
# 中にあるファイルごと消される可能性がありそう。
# そのため、メソッド内で自分で temporary directory を作成する。
#
# 没案
#   rename_rule メソッドをデフォルトで例外にしておいて、
#   コマンドスクリプト側で定義するという方法は、
#   メソッドの引数で ArgumentError のもとになり、
#   自由度が少なくなる。
#   たとえば old_str, new_str を渡したい時と、
#   更新時刻でリネームしたいときでは必要な引数の数が異なる。
class FileRenamer::Commander
  attr_reader :files

  class NoRenameRuleError < StandardError; end
  class OptionError < StandardError; end
  class ModeError < StandardError; end

  def self.files(strs)
    if strs.empty?
      return Dir::glob("*").sort
    else
      return strs
    end
  end

  #:yes と :no が両方 true ならば例外。
  #:copy, :move, :hardlink, :symlink, :git のうち、1つ以下が true。
  #全て nil ならば :move が true になる。
  #:quiet が true ならば自動的に :yes が立てられる。
  #:quiet が true で :no も true ならば例外。
  def initialize(options, files)
    @options = options

    if (@options[:yes] && @options[:no])
      raise OptionError, "Conflict options: --yes and --no."
    end

    fileProcessModes = []
    [:move, :copy, :hardlink, :symlink, :git].each do |mode|
      fileProcessModes << mode if @options[mode]
    end
    # mode が1つもなければ :move に。
    @options[:move] = true if fileProcessModes == []
    # 2つ以上あれば例外。
    if fileProcessModes.size > 1
      raise OptionError,
        "File process modes duplicate: #{fileProcessModes.join(", ")}"
    end

    @mode = :move      if @options[:move]
    @mode = :copy      if @options[:copy]
    @mode = :hardlink  if @options[:hardlink]
    @mode = :symlink   if @options[:symlink]
    @mode = :git       if @options[:git]

    case @mode
    when :move     ; then;  @command = "mv"
    when :copy     ; then;  @command = "cp -r"
    when :hardlink ; then;  @command = "ln"
    when :symlink  ; then;  @command = "ln -s"
    when :git      ; then;  @command = "git mv"
    else
      raise ModeError, "Unknown mode: #{@mode}"
    end

    @options[:yes] = true if @options[:quiet] # :quiet ならば自動的に :yes

    if @options[:quiet] && @options[:no] # :quiet と同時に :no なら例外
      raise OptionError, "Conflict options: --quiet and --no"
    end

    @files = self.class.files(files)
  end

  # 変更される名前のリストを表示し、ユーザの指示に従って実行する。
  # ユーザの入力は [y|Y] で始まる文字列ならば実行、
  # それ以外なら実行しない。
  # 新しい名前の生成方法をブロックで渡す。
  # ブロックがなければ例外 FileRenamerNoRenameRuleError
  def execute(&block)
    new_names = make_new_names(&block)

    if @mode == :move || @mode == :git
      ro = FileRenamer::RenameOrderer.new(new_names)
      ok_files = ro.rename_processes
      ng_files = ro.unable_processes
    else
      ok_files = []
      ng_files = []
      new_names.each do |old, new|
        if File.exist? new
          ng_files << [old, new]
        else
          ok_files << [old, new]
        end
      end
    end

    show_conversions(ok_files, "Enable files:")
    show_conversions(ng_files, "Unable files:")

    (puts "Execute? no"; return) if @options[:no]

    if ok_files.empty?
      puts "Done. No executable files." unless @options[:quiet]
      return
    end

    if @options[:yes]
      puts "Execute? yes" unless @options[:quiet]
    elsif (! ask_yes?)
      return
    end

    convert( ok_files)
  end

  private

  def show_conversions(conversions, heading)
    #STDOUT.puts conversions
    return if conversions.size == 0
    return if @options[:quiet]
    puts heading
    max_width = conversions.max_by{|old, new| old.width}[0].width
    conversions.each do |old, new|
      printf("  %s %s%s %s\n",
        @command, old, " " * (max_width - old.width), new
      )
    end
    puts
  end

  def make_new_names(&block)
    results = {}
    @files.each { |i| results[i] = yield i }
    return results
  end

  ## 新しい名前リストを受け取り、問題なくリネームできるものと
  ## できないものを選別する。
  ## OK, NG の順に2つの配列を返す。
  ##def ok_new_names(old_new_hash)
  ##end
  ##def ng_new_names(old_new_hash)
  #def check_new_names(old_new_hash)
  #  ok_files = {}
  #  ng_files = {}

  #  old_new_hash.each do |old, new|
  #    next if old == new # 変化がない場合は無視
  #    next if new == nil # 新しい名前に nil が定義されていたら無視

  #    #宛先が、宛先リスト内で重複していると、NG リスト入り
  #    if (old_new_hash.values.select{|name| name == new}.size > 1)
  #      ng_files[old] = new
  #      next
  #    end

  #    # 宛先パスにファイルが既存、かつ、元ファイル名リストに含まれていなければ、NG
  #    if FileTest.exist?(new) && ! old_new_hash.keys.include?(new)
  #      ng_files[old] = new
  #      next
  #    end

  #    ok_files[old] = new # 上記以外の場合ならば OK
  #  end
  #  return ok_files, ng_files
  #end

  # ユーザに判断を求める。
  # 標準入力から文字列を受け取り、
  # [y|Y] から始まる文字列なら true を、
  # それ以外なら false を返す。
  def ask_yes?
    puts "Execute?"
    if /^y/i =~ $stdin.gets
      return true
    else
      return false
    end
  end

  # コマンドを表示しつつ実行。
  # 既にファイルチェックされているはずなので、チェックはしない。
  # ディレクトリが必要になればここで作成。
  # ディレクトリが不要になればここで削除。
  def convert(conversions)
    #tmpdir = Dir.mktmpdir('rename', './')

    #int_paths = {} #intermediate paths
    #conversions.each { |old, new| int_paths[old] = tmpdir + '/' + old }
    #conversions.each { |old, new| int_paths[old] = tmpdir + '/' + old }
    #int_paths.each   { |old, int| transplant(old, int) }
    #int_paths.each   { |old, int| rmdir_p old }

    conversions.each { |old, new| transplant(old, new) }
    #int_paths.each   { |old, int| rmdir_p int }
  end

  # Move from root to root.
  # src_path and tgt_path are paths.
  def transplant(src_path, tgt_path)
    #pp src_path, tgt_path;exit
    # 変換先のディレクトリがなければ生成
    tgt_dir = File.dirname(tgt_path)
    unless FileTest.exist?(tgt_dir)
      #puts "  make directory: #{tgt_dir}" unless @options[:quiet]
      FileUtils.mkdir_p(tgt_dir)
    end

    # 変換の実行
    command = "  #{@command} #{src_path.escape_zsh} #{tgt_path.escape_zsh}"
    #puts command unless @options[:quiet]
    system(command)

    ##STDIN.gets
    # 変換元のディレクトリが空になっていれば削除
    src_dir = File.dirname(src_path)
    #pp Dir.entries(src_dir)
    if Dir.entries(src_dir).size == 2 # . と .. のみ
      #puts "  remove directory: #{src_dir}" unless @options[:quiet]
      rmdir_p(src_dir)
    end
  end

  # パスに含まれるディレクトリ名を、階層ごとに切り分けたソート済配列にして返す。
  # 最後の要素は含まない。
  # e.g. foo/bar/baz.txt => ["foo", "foo/bar"]
  # e.g. /foo/bar/baz.txt => ["/foo", "foo/bar"]
  def paths(path)
    dirs = path.split("/")
    results = []
    (dirs.size - 1).times do |i|
      results << dirs[0..i].join("/")
    end
    results.delete_at(0) if results[0] == ""
    return results
  end

  def rmdir_p(path)
    Pathname.new(path).ascend do |p_path|
      begin
        Dir.rmdir p_path
      rescue
        break
      end
    end
  end
end
