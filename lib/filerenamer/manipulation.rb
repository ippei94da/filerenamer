#! /usr/bin/env ruby
# coding: utf-8

# Abstract class for file manipulation.
#
#
class FileRenamer::Manipulation
  
  class NotImplementedError < Exception; end

  #
  def initialize
    raise NotImplementedError
  end

  def vanishing_file
    raise NotImplementedError
  end

  def appering_file
    raise NotImplementedError
  end

  def execute
    raise NotImplementedError
  end

end

