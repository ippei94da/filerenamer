#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class RenameOrderer
  attr_reader :rename_order, :unable_list
  # example of 'list'
  #   [
  #     [old0, new0],
  #     [old1, new1],
  #     ...
  #   ]
  def initialize(list)
    @all_list = Marshal.load(Marshal.dump(list))
    @rename_order = []
    @unable_list = []

    while ! list.empty?
      class_process( list[0] )
    end
  end

  private

  # 再帰的メソッド
  # その process と、依存する全ての process を @rename_order と @unable_list に分類する。
  # その process が実行可能であるか？ を返す。
  def class_process(process)
    old, new = process

    if new がどれかの dst と重複
      @unable_list << process
      return false
    end

    if new が既存のファイルではない
      @rename_order << process
      return true
    end

    if new が、他のいずれの process の old でもない
      @unable_list << process
      return false
    end

    if new が依存性チェーンの先頭と同じか？
      一時ファイルを置くプロセス、
      最後に一時ファイルを解決するプロセスを実行する工夫
      return true
    end

    #ここでの new からリネームするプロセスについて、再帰的に実行し、
    if class_process(new)
      @rename_order << process
      return true
    else
      @unable_list << process
      return false
    end
  end
end

