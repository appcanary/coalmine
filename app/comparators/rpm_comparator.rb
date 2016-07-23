class RPMComparator
  def initialize(package)
    @package = package
  end

  # is the current version identical, or more
  # recent, than the version constraint provided?

  def matches?(version_constraint)
    # it feels like AskingForTrouble to use two different
    # EVR parsers. So, let's just use the one we use elsewhere.
    constraint_evr = ::RPM::Nevra.new(version_constraint)
    current_evr = ::RPM::Nevra.from_package(@package)

    (constraint_evr <=> current_evr) <= 0
  end


end
