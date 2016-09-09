#! /usr/bin/env ruby
# coding: utf-8

require 'tempfile'

$DEBUG = false

#
#
#
class FileRenamer::RenameOrderer
  attr_reader :rename_processes, # in order
    :unable_processes
  # example of 'processes'
  #   [
  #     [old0, new0],
  #     [old1, new1],
  #     ...
  #   ]
  def initialize(olds_news, dir = '.')
    @dir = dir
    #@all_processes = processes.to_h
    @all_processes = olds_news
    @unworked_processes = Marshal.load(Marshal.dump(@all_processes))
    @rename_processes = []
    @unable_processes = []

    @post_processes = []
    while ! @unworked_processes.empty?
      key = @unworked_processes.keys[0]
      @first_old = key
      class_process(key)
    end
    @rename_processes += @post_processes unless @post_processes.empty?
    @post_processes = []

    @unable_processes.sort!
  end

  private

  # 再帰的メソッド
  # その process と、依存する全ての process を @rename_processes と @unable_processes に分類する。
  # その process が実行可能であるか？ を返す。
  def class_process(old)

    new = @unworked_processes[old]

    if $DEBUG
      puts "=" * 60
      pp self
      print "old "
      pp old
      print "new "
      pp new
      puts
    end

    # old と new が一致していれば不可
    if old == new
      puts "old(#{old}) == new(#{new}). retrun false." if $DEBUG
      add_unable(old, new)
      return false
    end
    puts "old(#{old}) != new(#{new})" if $DEBUG

    # old が存在しなければ不可
    unless FileTest.exist?("#{@dir}/#{old}")
      puts "old(#{old}) not exist in the file system. return false." if $DEBUG
      add_unable(old, new)
      return false
    end
    puts "old(#{old}) exist" if $DEBUG

    # new がどれかの dst と重複ならば、不可
    if @all_processes.values.select{|name| new == name}.size > 1
      puts "new(#{new}) is dpulicated in #{@all_processes.values}. return false." if $DEBUG
      add_unable(old, new)
      return false
    end
    puts "new(#{new}) is only one in new of @all_processes( #{@all_processes})" if $DEBUG

    unless File.exist?("#{@dir}/#{new}") # new がファイルとして存在しないならば、可能
      puts "new(#{new}) does not exist in the filesystem. return true." if $DEBUG
      add_rename(old, new)
      return true
    end
    puts "new(#{new}) exist in the filesystem" if $DEBUG

    # new がファイルとして存在する

    # 可能リストに入っていたら、ここまでにリネームされているので可能
    if @rename_processes.map{|o, n| o}.include?(new)
      puts "new(#{new}) is included in old of @rename_processes(#{@rename_processeses}). return true." if $DEBUG
      add_rename(old, new)
      return true
    end

    # new が、他のいずれかの process の old で ない ならば、空かないので不可
    unless @unworked_processes[new]
      puts "@unworked_processes[new](#{@unworked_processes[new] }). return false." if $DEBUG
      add_unable(old, new)
      return false
    end

    # new が、他のいずれかの process の old で ある

    # new が依存性チェーンの先頭と同じであれば、
    # 先頭を一時ファイルにリネームして、その上でリネーム可能とし、
    # 最後に一時ファイルからリネームする処理を追加。
    if new == @first_old
      puts "new #{new} == first_old #{@first_old}. use tmp file and return true." if $DEBUG
      #tmp = Tempfile.new("#{@first_old}-", @dir).path
      tmp = Tempfile.new("#{@all_processes[@first_old]}-#{@first_old}-", @dir).path
      add_rename(@first_old, tmp)
      @post_processes << [tmp, @all_processes[@first_old]]
      pp self if $DEBUG
      return true
    end
    puts "new(#{new}) != first_old(#{@first_old})" if $DEBUG

    puts "class_process(new)" if $DEBUG
    pp self if $DEBUG
    #ここでの new からリネームするプロセスについて、再帰的に実行
    if class_process(new)
      pp self if $DEBUG
      puts "depending process can be executed. return true." if $DEBUG
      #add_rename(old, new) unless @rename_processes.map{|o, n| o}.include?(old)
      #add_rename(old, new)
      return true
    else
      puts "depending process cannot be executed. return false." if $DEBUG
      add_unable(old, new)
      return false
    end
  end

  private
  
  def add_rename(old, new)
    @rename_processes << [old, new]
    @unworked_processes.delete(old)
    return true
  end

  def add_unable(old, new)
    @unable_processes << [old, new]
    @unworked_processes.delete(old)
    return false
  end

end

