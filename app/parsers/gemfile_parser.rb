require 'bundler'
require 'bundler/lockfile_parser'

# Set this so that expand_path works correctly which is used by Bundler to compute a gem hash when gems are sourced from path
# ENV["HOME"]="/tmp/"

# TODO: handle errors?
# test
class GemfileParser
  include ResultObject
  def self.parse(lockfile)
    begin
      lf = Bundler::LockfileParser.new(lockfile)
      # old version; what do we do about the platform?
      # lf.specs.map {|a| {name: a.name, kind: "rubygem", version:  {number: a.version.version, platform: a.platform.to_s}}}
      # lf.specs.map {|a| {name: a.name, kind: "rubygem", version: a.version.version, platform: a.platform.to_s}}

      pkgs = lf.specs.map {|a| Parcel::Rubygem.new(name: a.name,  version: a.version.version, platform: a.platform.to_s) }
      Result.new(pkgs, nil)
    rescue Exception => e
      Result.new(nil, e)
    end
  end
end

