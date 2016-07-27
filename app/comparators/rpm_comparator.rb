class RPMComparator
  def initialize(package)
    @package = package
    @current_evr = ::RPM::Nevra.from_package(@package)
  end

  # is the current version identical, or more
  # recent, than the version constraint provided?

  def matches?(version_constraint)
    # it feels like AskingForTrouble to use two different
    # EVR parsers. So, let's just use the one we use elsewhere.
    constraint_evr = ::RPM::Nevra.new(version_constraint)

    # ignore packages that are not el7, since we only nominally
    # support el7 packages. Should also check arch n'est pas?
    if constraint_evr.release =~ /el7/

      (constraint_evr <=> @current_evr) <= 0
    else
      false
    end
  end

  def earlier_version?(version_constraint)
    constraint_evr = ::RPM::Nevra.new(version_constraint)
    if constraint_evr.release =~ /el7/
      (constraint_evr <=> @current_evr) < 0
    else
      false
    end
  end


end
