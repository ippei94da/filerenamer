#! /usr/bin/env ruby
# coding: utf-8

# Abstract class for file manipulation.
#
#
class FileRenamer::Manipulation

  attr_reader :files
  
  class NotImplementedError < Exception; end
  class ArgumentError < Exception; end

  #
  def initialize(* files)
    raise NotImplementedError
  end

  def vanishing_files
    raise NotImplementedError
  end

  def appearing_files
    raise NotImplementedError
  end

  def execute(flag_show = true)
    raise NotImplementedError
  end

  def to_s
    #[self::UNIX_COMMAND, *@files].join(" ")
    raise NotImplementedError
  end

  def ==(other)
    return false unless self.class == other.class
    return false unless self.files == other.files
    return true
  end

  private

  def recursive_paths(path)
    results = []
    Find.find(path) do |child|
      results << child
    end
    results
  end

end

