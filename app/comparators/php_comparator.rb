class PHPComparator
  attr_accessor :version

  def initialize(version_str)
    @version = version_str
  end

  def satisfies?(constraints)
    # Going to assume this means "satisfies"
    if constraints.is_a?(Array)
      constraint_checker.satisfies(@version, constraints)
    elsif constraints.is_a?(String)
      constraint_checker.satisfied_by(constraints, @version)
    end
  end

  def vercmp(v1, v2)
    case
    when comparator.less_than?(v1, v2)    then -1
    when comparator.greater_than?(v1, v2) then 1
    when comparator.equal_to?(v1, v2)     then 0
    end
  end

  private

  def comparator
    Composer::Semver::Comparator
  end

  def constraint_checker
    Composer::Semver::Semver
  end
end
