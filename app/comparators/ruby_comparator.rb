class RubyComparator
  attr_accessor :version
  def initialize(version)
    @version = Gem::Version.create(version)
  end

  def matches?(requirement)
    gem_requirement = Gem::Requirement.new(*requirement.split(', '))

    gem_requirement === @version
  end
end
