# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: filerenamer 0.0.8 ruby lib

Gem::Specification.new do |s|
  s.name = "filerenamer"
  s.version = "0.0.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["ippei94da"]
  s.date = "2015-07-23"
  s.description = "This library provide common dealing to rename many files with safe method. Automatically mkdir if need and rmdir when empty."
  s.email = "ippei94da@gmail.com"
  s.executables = ["classify", "classify_greed", "renhash", "rennum", "renpad", "renpar", "renreg", "rensub", "rentime"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "CHANGES",
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/classify",
    "bin/classify_greed",
    "bin/renhash",
    "bin/rennum",
    "bin/renpad",
    "bin/renpar",
    "bin/renreg",
    "bin/rensub",
    "bin/rentime",
    "filerenamer.gemspec",
    "lib/filerenamer.rb",
    "lib/filerenamer/commander.rb",
    "lib/filerenamer/optionparser.rb",
    "test/classify/123",
    "test/classify/abc",
    "test/classify/abcd",
    "test/classify/abcdefghij",
    "test/classify/def",
    "test/classify/がぎぐ",
    "test/classify/ゃゅょ",
    "test/classify/月火水",
    "test/filerenamer/a0.txt",
    "test/filerenamer/dummy.txt",
    "test/filetreesimulator/00",
    "test/filetreesimulator/dir00/01",
    "test/filetreesimulator/dir00/02",
    "test/filetreesimulator/test_file.rb",
    "test/helper.rb",
    "test/renhash/)(.txt",
    "test/renhash/0.txt",
    "test/rennum/a",
    "test/rennum/b",
    "test/rennum/c",
    "test/rennum/d",
    "test/renpad/1",
    "test/renpad/10",
    "test/renpad/100",
    "test/renpad/100b",
    "test/renpad/10b",
    "test/renpad/1b",
    "test/renpad/a1",
    "test/renpad/a10",
    "test/renpad/a100",
    "test/renpad/a100b",
    "test/renpad/a10b",
    "test/renpad/a1b",
    "test/renpar/((ab)(cd(ef))gh(ij)kl(mn).txt",
    "test/renpar/(ab)(cd(ef)))gh(ij)kl(mn).txt",
    "test/renpar/(ab)(cd(ef))gh(ij)kl(mn).txt",
    "test/renpar/(ab)(cd).txt",
    "test/renreg/a(b)",
    "test/renreg/１",
    "test/renreg/ａ",
    "test/rensub/a0",
    "test/rensub/a1",
    "test/rensub/b0",
    "test/rensub/b1",
    "test/test_commander.rb",
    "test/test_filetreesimulator.rb",
    "test/test_optionparser.rb"
  ]
  s.homepage = "http://github.com/ippei94da/filerenamer"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Library to rename filenames."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<test-unit>, ["~> 3.1.2"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0.1"])
      s.add_development_dependency(%q<bundler>, ["~> 1.10.5"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<builtinextension>, ["~> 0.1.0"])
      s.add_development_dependency(%q<capture_stdout>, ["~> 0.0"])
    else
      s.add_dependency(%q<test-unit>, ["~> 3.1.2"])
      s.add_dependency(%q<rdoc>, ["~> 4.0.1"])
      s.add_dependency(%q<bundler>, ["~> 1.10.5"])
      s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<builtinextension>, ["~> 0.1.0"])
      s.add_dependency(%q<capture_stdout>, ["~> 0.0"])
    end
  else
    s.add_dependency(%q<test-unit>, ["~> 3.1.2"])
    s.add_dependency(%q<rdoc>, ["~> 4.0.1"])
    s.add_dependency(%q<bundler>, ["~> 1.10.5"])
    s.add_dependency(%q<jeweler>, ["~> 2.0.1"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<builtinextension>, ["~> 0.1.0"])
    s.add_dependency(%q<capture_stdout>, ["~> 0.0"])
  end
end

