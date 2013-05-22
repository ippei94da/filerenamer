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
    f_path = File::expand_path f_path
    t_path = File::expand_path t_path

    reflect_from_filesystem(f_path)
    reflect_from_filesystem(t_path)

    unless @files[f_path]
      raise NoEntryError, "No such file or directory - #{f_path}"
    end

    @files.keys.select{ |path| path =~ /^#{fpath}/} do |path|
      pp path
      #@files[t_path] = @files[f_path]
      #@files[f_path] = false
    end
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
    path = File::expand_path path
    return if @files.has_key? path # already fetched; do nothing.

    if File.exist? path
      Find.find(path) do |fpath|
        @files[fpath] = File.ftype(fpath).intern
      end
    else
      @files[path] = false
    end
  end


end

