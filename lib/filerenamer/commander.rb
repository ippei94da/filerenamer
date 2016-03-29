#! /usr/bin/env ruby
# coding: utf-8

require "rubygems"
gem "builtinextension"
require "string/escapezsh.rb"
require "string/width.rb"

require "fileutils"
require "optparse"
require "filerenamer/optionparser.rb"

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
module FileRenamer
  class Commander
    attr_reader :files

    class NoRenameRuleError < Exception; end
    class OptionError < Exception; end

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
        raise OptionError,
          "Conflict options: --yes and --no."
      end

      fileProcessModes = []
      [:move, :copy, :hardlink, :symlink, :git].each do |mode|
        fileProcessModes << mode if @options[mode]
      end
      # 1つもなければ :move に。
      @options[:move] = true if fileProcessModes == []
      # 2つ以上あれば例外。
      if fileProcessModes.size > 1
        raise OptionError,
          "File process modes duplicate: #{fileProcessModes.join(", ")}"
      end
      @command = "mv"     if @options[:move]
      @command = "cp -r"  if @options[:copy]
      @command = "ln"     if @options[:hardlink]
      @command = "ln -s"  if @options[:symlink]
      @command = "git mv" if @options[:git]

      # :quiet ならば自動的に :yes
      @options[:yes] = true if @options[:quiet]

      # :quiet と同時に :no なら例外
      if @options[:quiet] && @options[:no]
        raise OptionError,
          "Conflict options: --quiet and --no"
      end

      @files = self.class.files(files)
    end

    # 変更される名前のリストを表示し、ユーザの指示に従って実行する。
    # ユーザの入力は [y|Y] で始まる文字列ならば実行、
    # それ以外なら実行しない。
    # files は対象のファイル名のリスト。
    # 新しい名前の生成方法をブロックで渡す。
    # ブロックがなければ例外 FileRenamerNoRenameRuleError
    def execute(&block)
      new_names = make_new_names(&block)

      ok_files, ng_files = check_new_names(new_names)

      unless @options[:quiet]
        if ok_files.size > 0
          puts "Enable files:"
          max_width = ok_files.keys.max_by{|file| file.width}.width
          ok_files.keys.sort.each do |old|
            printf("  %s %s%s %s\n",
              @command, old, " " * (max_width - old.width), ok_files[old]
            )
          end
        end

        if ng_files.size > 0
          puts "Unable files:"
          max_width = ng_files.keys.max_by{|file| file.width}.width
          ng_files.keys.sort.each do |old|
            printf("  %s %s%s %s\n",
              @command, old, " " * (max_width - old.width), ng_files[old]
            )
          end
        puts
        end
      end

      if ok_files.empty?
        puts "Done. No executable files." unless @options[:quiet]
        return
      elsif @options[:no]
        puts "Execute? no"
        return
      end

      if @options[:yes]
        puts "Execute? yes" unless @options[:quiet]
      elsif (! ask_yes?)
        return
      end
      ok_files.each do |old, new|
        run(old, new)
      end
    end

    private

    def make_new_names(&block)
      #pp @files
      results = {}
      @files.each { |i| results[i] = yield i }
      return results
    end

    # 新しい名前リストを受け取り、問題なくリネームできるものと
    # できないものを選別する。
    # OK, NG の順に2つの配列を返す。
    #
    # 判断基準は、以下の AND 条件。
    #   - 新しい名前が古い名前リストに含まれないこと。
    #   - 新しい名前が新しい名前リストに1つ(自分)のみしかないこと。
    #   - 新しい名前のファイルが既に存在しないこと。
    #
    # 没案
    #   新しい名前が変換されない古い名前であれば、
    #   これも NG リストに追加する。(表示用)
    #   このルールにすると、変換に順序依存が生じる可能性があり、
    #   temporary directory を経由する必要ができる。
    #   その結果、リネーム過程で深い temporary directory を
    #   作成したり削除したりしなければならなくなる。
    def check_new_names(old_new_hash)
      ok_files = {}
      ng_files = {}

      old_new_hash.each do |old, new|
        # 変化がない場合はスルー
        next if old == new

        # 新しい名前に nil が定義されていてもスルー
        next if new == nil

        # 既に存在していれば、既に存在するファイルごと NG に登録。
        if FileTest.exist?(new)
          ng_files[old] = new
          ng_files[new] = new
          next
        end

        # new が複数 重複していれば、 NG。
        if (old_new_hash.values.select{|name| name == new}.size > 1)
          ng_files[old] = new
          next
        end

        # new が old に含まれていれば、NG。
        if (old_new_hash.keys.include?(new))
          ng_files[old] = new
          next
        end

        # 上記以外の場合ならば OK

        ok_files[old] = new
      end
      return ok_files, ng_files
    end

    # ユーザに判断を求める。
    # 標準入力から文字列を受け取り、
    # [y|Y] から始まる文字列なら true を、
    # それ以外なら false を返す。
    def ask_yes?
      puts "Execute?"
      str = $stdin.gets
      if /^y/i =~ str
        return true
      else
        return false
      end
    end

    # コマンドを表示しつつ実行。
    # 既にファイルチェックされているはずなので、チェックはしない。
    # 少なくとも当面は。
    # ディレクトリが必要ならここで作成。
    # ディレクトリが不要になればここで削除。
    # 本来ここでない方が分かり易い気もするのだが、ここに追加するのが一番簡単なので。
    def run(old, new)
      # 変換先のディレクトリがなければ生成
      #pp old, new; exit
      paths(new).each do |directory|
        unless FileTest.exist?(directory)
          puts "  make directory: #{directory}" unless @options[:quiet]
          FileUtils.mkdir_p(directory)
        end
      end

      # 変換の実行
      command = "  #{@command} #{old.escape_zsh} #{new.escape_zsh}"
      puts command unless @options[:quiet]
      system(command)

      # 変換元のディレクトリが空になっていれば削除
      dirs = paths(old)
      dirs.reverse.each do |directory|
        if Dir.entries(directory).size == 2 # . と .. のみ
          puts "  remove directory: #{directory}" unless @options[:quiet]
          Dir.rmdir(directory)
        end
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
  end
end
