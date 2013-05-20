#! /usr/bin/env ruby
# coding: utf-8

# Abstract class for file manipulation.
#
#
class FileRenamer::Manipulation::Mv
  TODO
  
  class NotImplementedError < Exception; end
  class ArgumentError < Exception; end

  NUM_ARGS = nil
  UNIX_COMMAND = nil

  #
  def initialize(* files)
    raise NotImplementedError unless NUM_ARGS
    raise ArgumentError unless files.size == NUM_ARGS
    @files = files
  end

  def vanishing_file
    raise NotImplementedError
  end

  def appering_file
    raise NotImplementedError
  end

  def execute(flag_show = true)
    puts to_s
    raise NotImplementedError
  end

  def to_s
    [UNIX_COMMAND, *@files].join(" ")
  end

end

