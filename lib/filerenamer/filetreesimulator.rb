#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class FileRenamer::FileTreeSimulator

#  class FileExistError < Exception; end
#  class NoEntryError < Exception; end
#  class NotPermittedOperationError < Exception; end
#
#  #
#  def initialize
#    @files = {}
#  end
#
#  #mv, rename file.
#  #Overwrite if t_file exists.
#  def mv(f_path, t_path)
#    f_path = File::expand_path f_path
#    t_path = File::expand_path t_path
#
#    reflect_from_filesystem(f_path)
#    reflect_from_filesystem(t_path)
#
#    unless @files[f_path]
#      raise NoEntryError, "No such file or directory - #{f_path}"
#    end
#
#    @files.keys.select{|path| path =~ /^#{f_path}/}.each do |old_path|
#      new_path = old_path.sub(/^#{f_path}/, t_path)
#      @files[new_path] = @files[old_path]
#      @files[old_path] = false
#    end
#  end
#
#  def cp_r(f_path, t_path)
#    f_path = File::expand_path f_path
#    t_path = File::expand_path t_path
#
#    reflect_from_filesystem(f_path)
#    reflect_from_filesystem(t_path)
#
#    unless @files[f_path]
#      raise NoEntryError, "No such file or directory - #{f_path}"
#    end
#
#    @files.keys.select{|path| path =~ /^#{f_path}/}.each do |old_path|
#      new_path = old_path.sub(/^#{f_path}/, t_path)
#      @files[new_path] = @files[old_path]
#    end
#  end
#
#  def ln(f_path, t_path)
#    f_path = File::expand_path f_path
#    t_path = File::expand_path t_path
#
#    reflect_from_filesystem(f_path)
#    reflect_from_filesystem(t_path)
#
#    unless @files[f_path]
#      raise NoEntryError, "No such file or directory - #{f_path}"
#    end
#
#    if @files[f_path] == :directory
#      raise NotPermittedOperationError,
#      "Operation not permitted - (#{f_path}, #{t_path})"
#    end
#    @files[t_path] = @files[f_path]
#  end
#
#  def ln_s(f_path, t_path)
#    f_path = File::expand_path f_path
#    t_path = File::expand_path t_path
#
#    reflect_from_filesystem(f_path)
#    reflect_from_filesystem(t_path)
#
#    unless @files[f_path]
#      raise NoEntryError, "No such file or directory - #{f_path}"
#    end
#
#    @files[t_path] = :link
#  end
#
#  def mkdir_p(path)
#    path = File::expand_path path
#    reflect_from_filesystem(path)
#
#    if @files[path]
#      raise FileExistsError, "File exists - #{path}"
#    end
#
#    #@files[t_path] = :link
#  end
#
#  def rmdir_p(dir)
#  end
#
#  def rm(path)
#  end
#
#  private
#
#  #def check_2file_method(
#  #end
#
#  def reflect_from_filesystem(path)
#    path = File::expand_path path
#    return if @files.has_key? path # already fetched; do nothing.
#
#    if File.exist? path
#      Find.find(path) do |fpath|
#        @files[fpath] = File.ftype(fpath).intern
#      end
#    else
#      @files[path] = false
#    end
#  end

end

