class DpkgComparator
  def initialize(package)
    @current_evr = Dpkg::Evr.from_s(package.version)
  end

  def matches?(version_constraint)
    constraint_evr = Dpkg::Evr.from_s(version_constraint)
    (constraint_evr <=> @current_evr) <= 0
  end

  def earlier_version?(version_constraint)
    constraint_evr = Dpkg::Evr.from_s(version_constraint)
    (@current_evr <=> constraint_evr) < 0
  end
end
