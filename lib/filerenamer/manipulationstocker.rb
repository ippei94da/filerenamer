#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class FileRenamer::ManipulationStocker
  #
  def initialize()
  end

  #from and to are filenames.
  def add_cp(from, to)
  end

  def add_mv(from, to)
  end

  #symlink
  def add_ln_s(from, to)
  end

  #hardlink
  def add_ln(from, to)
  end

  def add_rm(filename)
  end

  def add_rmdir(filename)
  end

  def add_mkdir(filename)
  end

  #Show 
  def show(io = $stdout)
  end

  def execute(flag_ask)
  end

  private

  def ask
  end

end

