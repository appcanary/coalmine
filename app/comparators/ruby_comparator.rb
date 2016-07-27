class RubyComparator
  attr_accessor :version
  def initialize(pkg)
    @version = Gem::Version.create(pkg.version)
  end

  def matches?(requirement)
    gem_requirement = Gem::Requirement.new(*requirement.split(', '))

    gem_requirement === @version
  end

  def vercmp(requirement)
    patched_version = requirement.split(/\s+/).last

    @version <=> Gem::Version.create(patched_version)
  end

  def earlier_version?(req)
    vercmp(req) < 0
  end
end
