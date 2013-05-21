#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class FileRenamer::FileTreeSimulator
  #
  def initialize
    @files = {}
  end

  def mv(f_file, t_file)
    reflect_from_filesystem(f_file)
    reflect_from_filesystem(t_file)

    unless @files[f_file]
      raise Errno::ENOENT, "No such file or directory - #{f_file}"
    end
    t_file が存在しても、普通に FileUtils.mv すると上書きしてしまう。

    File.ftype() #=> "file", "directory", etc.

    @files[t_file] = @files[f_file]
    @files[f_file] = false
  end

  def cp(f_file, t_file)
  end

  def ln(f_file, t_file)
  end

  def ln_s(f_file, t_file)
  end

  def mkdir_p(dir)
  end

  def rmdir_p(dir)
  end

  def rm(file)
  end

  private

  def reflect_from_filesystem(file)
    if @files[file]
      return
    else
      if File.exist? file
        @files[file] = File.ftype(file).intern
      else
        @files[file] = false
      end
    end
  end

end

