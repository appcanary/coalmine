class RubyComparator
  attr_accessor :version
  def initialize(version_str)
    @version = Gem::Version.create(version_str)
  end

  def matches?(requirement)
    gem_requirement = Gem::Requirement.new(*requirement.split(', '))

    gem_requirement === @version
  end

  # assumes both are requirements?
  def vercmp(areq,breq)
    a = areq.split(/\s+/).last
    b = breq.split(/\s+/).last
    Gem::Version.create(a) <=> Gem::Version.create(b)
  end

  def reqcmp(requirement)
    patched_version = requirement.split(/\s+/).last

    @version <=> Gem::Version.create(patched_version)
  end

  def earlier_version?(req)
    reqcmp(req) < 0
  end
end
