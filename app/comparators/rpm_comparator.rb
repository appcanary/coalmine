class RPMComparator
  def initialize(version_str)
    @current_evr = ::RPM::Nevra.new(version_str)
  end

  # is the current version identical, or more
  # recent, than the version constraint provided?

  def satisfies?(version_constraint)
    # it feels like AskingForTrouble to use two different
    # EVR parsers. So, let's just use the one we use elsewhere.
    constraint_evr = ::RPM::Nevra.new(version_constraint)

    (constraint_evr <=> @current_evr) <= 0
  end

  def vercmp(a,b)
    ::RPM::Nevra.new(a) <=> ::RPM::Nevra.new(b)
  end
end
