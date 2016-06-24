require 'bundler'
require 'bundler/lockfile_parser'

# Set this so that expand_path works correctly which is used by Bundler to compute a gem hash when gems are sourced from path
# ENV["HOME"]="/tmp/"

class GemfileParser
  def self.parse(lockfile)
    lf = Bundler::LockfileParser.new(lockfile)
    # old version; what do we do about the platform?
    # lf.specs.map {|a| {name: a.name, kind: "rubygem", version:  {number: a.version.version, platform: a.platform.to_s}}}
    lf.specs.map {|a| {name: a.name, kind: "rubygem", version: a.version.version, platform: a.platform.to_s}}
  end
end

