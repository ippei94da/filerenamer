#! /usr/bin/env ruby
# coding: utf-8

require 'tempfile'

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
  def initialize(processes, dir = '.')
    @dir = dir
    @all_processes = processes.to_h
    @unworked_processes = Marshal.load(Marshal.dump(@all_processes))
    @rename_processes = []
    @unable_processes = []

    while ! @unworked_processes.empty?
      key = @unworked_processes.keys[0]
      @first_old = key
      @post_processes = []
      class_process(key)
      @rename_processes += @post_processes if @post_processes
    end

    @unable_processes.sort!
  end

  private

  # 再帰的メソッド
  # その process と、依存する全ての process を @rename_processes と @unable_processes に分類する。
  # その process が実行可能であるか？ を返す。
  def class_process(old)

    new = @unworked_processes[old]
    @unworked_processes.delete(old)

    #pp self
    #print "old"
    #pp old
    #print "new"
    #pp new
    #puts

    #pp @all_processes.values

    #unless FileTest.exist?("#{@dir}/#{old}")
    #  @unable_processes << [old, new]
    #  return false
    #end

    # new がどれかの dst と重複ならば、不可
    if @all_processes.values.select{|name| new == name}.size > 1
      @unable_processes << [old, new]
      return false
    end

    #puts "A"

    unless File.exist?("#{@dir}/#{new}") # new がファイルとして存在しないならば、
      @rename_processes << [old, new]
      return true
    end

    # new がファイルとして存在する
    #puts "B"

    # new が、他のいずれかの process の old で ない ならば、
    if @rename_processes.map{|old, new| old}.include?(new)
      @rename_processes << [old, new]
      return
    end
    #puts "C"
    #unless @unworked_processes.keys.include?(new)
    #  @unable_processes << [old, new]
    #  return false
    #end

    # new が、他のいずれかの process の old で ある
    #puts "D"

    # new が依存性チェーンの先頭と同じであれば、
    # 先頭を一時ファイルにリネームして、その上でリネーム可能とし、
    # 最後に一時ファイルからリネームする処理を追加。
    if new == @first_old
      tmp = Tempfile.new("#{@first_old}-", @dir).path
      @rename_processes << [@first_old, tmp]
      @rename_processes << [old, new]
      @post_processes << [tmp, @all_processes[@first_old]]
      return true
    end
    #puts "E"

    #ここでの new からリネームするプロセスについて、再帰的に実行し、
    if class_process(new)
      @rename_processes << [old, new] unless @rename_processes.map{|o, n| o}.include?(old)
      return true
    else
      @unable_processes << [old, new]
      return false
    end
  end
end

