#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class FileRenamer::ManipulationQueue
  #
  def initialize()
    @manipulations = []
  end

  #f_file and t_file are filenames of from and to, respectively.
  def enqueue_cp(f_file, t_file)
    @manipulations << FileRenamer::Manipulation::Cp.new(f_file, t_file)
  end

  #f_file and t_file are filenames of from and to, respectively.
  def enqueue_mv(f_file, t_file)
    @manipulations << FileRenamer::Manipulation::Mv.new(f_file, t_file)
  end

  #symlink
  def enqueue_ln_s(f_file, t_file)
    @manipulations << FileRenamer::Manipulation::Lns.new(f_file, t_file)
  end

  #hardlink
  def enqueue_ln(f_file, t_file)
    @manipulations << FileRenamer::Manipulation::Ln.new(f_file, t_file)
  end

  #def enqueue_rm(file)
  #  @manipulations << FileRenamer::Manipulation::Rm.new(f_file)
  #end

  #Simulate file manipulation and show results.
  def simulate(io = $stdout)
  end

  #dequeue
  def execute(flag_ask)
  end

  private

  def ask
  end

end

