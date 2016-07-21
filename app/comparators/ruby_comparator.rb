class RubyComparator
  attr_accessor :version
  def initialize(pkg)
    @version = Gem::Version.create(pkg.version)
  end

  def matches?(requirement)
    gem_requirement = Gem::Requirement.new(*requirement.split(', '))

    gem_requirement === @version
  end
end
