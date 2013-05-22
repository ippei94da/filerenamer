#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class FileRenamer::FileTreeSimulator

  class NoEntryError < Exception; end

  #
  def initialize
    @files = {}
  end

  #mv, rename file.
  #Overwrite if t_file exists.
  def mv(f_path, t_path)
    reflect_from_filesystem(f_path)
    reflect_from_filesystem(t_path)

    unless @files[f_path]
      raise NoEntryError, "No such file or directory - #{f_path}"
    end

    @files[t_path] = @files[f_path]
    @files[f_path] = false
  end

  def cp(f_path, t_path)
  end

  def ln(f_path, t_path)
  end

  def ln_s(f_path, t_path)
  end

  def mkdir_p(dir)
  end

  def rmdir_p(dir)
  end

  def rm(path)
  end

  private

  def reflect_from_filesystem(path)
    if @files[path]
      return
    else
      if File.exist? path
        @files[path] = File.ftype(path).intern
      else
        @files[path] = false
      end

      if @files[path] == :directory
        Dir.glob(path).each do |subdir|
          reflect_from_filesystem subdir
        end
      end
    end
  end

end

