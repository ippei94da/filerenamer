#! /usr/bin/env ruby
# coding: utf-8

require "find"

# Abstract class for file manipulation.
#
#
class FileRenamer::Manipulation::Mkdirp < FileRenamer::Manipulation

  class NotImplementedError < Exception; end
  class ArgumentError < Exception; end

  def initialize(*files)
    raise ArgumentError unless files.size == 2
    @files = files
  end

  #Return a filename which is vanished after 'execute'.
  def vanishing_files
    []
  end

  #Return a filename which is generated after 'execute'.
  def appearing_files
    recursive_paths(@files[0]).map{|path| path.sub(@files[0], @files[1])}
  end

  #If io is nil, no output string.
  def execute(io = $stdio)
    io.puts to_s if io
    TODO
    FileUtils.cp_r(@files[0], @files[1])
  end

  #Return string like UNIX command.
  def to_s
    "mkdir -p #{@files[0]} #{@files[1]}"
  end

end

