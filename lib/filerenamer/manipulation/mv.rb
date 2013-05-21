#! /usr/bin/env ruby
# coding: utf-8

# Abstract class for file manipulation.
#
#
class FileRenamer::Manipulation::Mv < FileRenamer::Manipulation

  class NotImplementedError < Exception; end
  class ArgumentError < Exception; end

  #NUM_ARGS = 2
  #UNIX_COMMAND = "mv"
  
  def initialize(*files)
    #raise NotImplementedError, "Not set NUM_ARGS" unless NUM_ARGS
    raise ArgumentError unless files.size == NUM_ARGS
    @files = files
  end

  def vanishing_file
    @files[0]
  end

  def appering_file
    @files[1]
  end

  def execute(io)
    puts to_s
    raise NotImplementedError
  end

  private
  
  def

end

