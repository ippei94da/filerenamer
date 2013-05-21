require "fileutils"
require "filerenamer/commander.rb"
require "filerenamer/optionparser.rb"
require "filerenamer/manipulation.rb"
require "filerenamer/manipulation/mv.rb"
require "filerenamer/manipulation/cp.rb"
require "filerenamer/manipulation/ln.rb"
require "filerenamer/manipulation/lns.rb"
#require "filerenamer/manipulation/rm.rb"
require "filerenamer/manipulationqueue.rb"
#require "filerenamer/manipulation/mkdirp.rb" not prepare due to ambiguous behavior.
#require "filerenamer/manipulation/rmdirp.rb" not prepare due to ambiguous behavior.

module FileRenamer; end
