class DpkgComparator
  def initialize(version_str)
    @current_evr = Dpkg::Evr.from_s(version_str)
  end

  def matches?(version_constraint)
    constraint_evr = Dpkg::Evr.from_s(version_constraint)
    (constraint_evr <=> @current_evr) <= 0
  end

  def earlier_version?(version_constraint)
    constraint_evr = Dpkg::Evr.from_s(version_constraint)
    (@current_evr <=> constraint_evr) < 0
  end

  def vercmp(a,b)
    Dpkg::Evr.from_s(a) <=> Dpkg::Evr.from_s(b)
  end
end
