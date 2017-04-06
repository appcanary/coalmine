class PHPComparator
  attr_accessor :version

  def initialize(version_str)
    self.version = version_str
  end

  def satisfies?(constraints)
    constraint_checker.satisfies?(self.version, constraints)
  end

  def vercmp(v1, v2)
    case
    when comparator.less_than?(v1, v2)    then -1
    when comparator.greater_than?(v1, v2) then 1
    when comparator.equal_to?(v1, v2)     then 0
    else
      raise "v1 (#{v1}) isn't greater than, equal to or less than v2 (#{v2}) ¯\_(ツ)_/¯"
    end
  end

  private

  def comparator
    ::Composer::Semver::Comparator
  end

  def constraint_checker
    ::Composer::Semver::Semver
  end
end
