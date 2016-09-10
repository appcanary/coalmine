class RPMComparator
  def initialize(package)
    @package = package
    @current_evr = ::RPM::Nevra.new(@package.version)
  end

  # is the current version identical, or more
  # recent, than the version constraint provided?

  def matches?(version_constraint)
    # it feels like AskingForTrouble to use two different
    # EVR parsers. So, let's just use the one we use elsewhere.
    constraint_evr = ::RPM::Nevra.new(version_constraint)

    (constraint_evr <=> @current_evr) <= 0
  end

  def earlier_version?(version_constraint)
    constraint_evr = ::RPM::Nevra.new(version_constraint)
    (constraint_evr <=> @current_evr) < 0
  end
end
