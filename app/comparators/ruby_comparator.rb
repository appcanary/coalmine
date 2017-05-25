class RubyComparator
  attr_accessor :version
  def initialize(version_str)
    @version = Gem::Version.create(version_str)
  end

  def satisfies?(constraint)
    gem_requirement = Gem::Requirement.new(*constraint.split(', '))

    gem_requirement === @version
  end

  # assumes both are requirements?
  def vercmp(areq,breq)
    a = areq.split(/\s+/).last
    b = breq.split(/\s+/).last
    Gem::Version.create(a) <=> Gem::Version.create(b)
  end
end
