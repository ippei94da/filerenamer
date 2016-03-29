#! /usr/bin/env ruby
# coding: utf-8

require "optparse"

# FileRenamer 用のオプション解析器。
# ユーザはこれに任意のオプションを追加できる。
#
# 通常の OptionParser と異なり、インスタンス変数 @options に情報を格納する。
# @options は attr_reader に指定されているので、外部から読み取れる。
# @options は Hash であるので、ユーザが on で追加するブロックで
# そのまま鍵と値を追加できる。
# また、@options に追加せずに自前で何か適当な処理をしても良い。
module FileRenamer
  class OptionParser < OptionParser

    attr_reader :options

    def initialize
      @options = {}
      super
      on("-y", "--yes"     , "Yes for all questions."){@options[:yes]     = true}
      on("-n", "--no"      , "No  for all questions."){@options[:no]      = true}
      on("-c", "--copy"    , "Copy mode."            ){@options[:copy]    = true}
      on("-m", "--move"    , "Move mode.(default)"   ){@options[:move]    = true}
      on("-h", "--hardlink", "Hardlink mode."        ){@options[:hardlink]= true}
      on("-s", "--symlink" , "Symlink mode."         ){@options[:symlink] = true}
      on("-g", "--git"     , "Git-mv mode."          ){@options[:git] = true}
      on("-q", "--quiet"   , "Quiet mode. Forced non-interactive."){
        @options[:quiet] = true
        #このオプションが設定されているときは強制的に --yes として扱われる。
        #non_interactive_mode になる。
      }
    end
  end
end
