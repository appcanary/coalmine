class PHPComparator
  attr_accessor :version

  def initialize(version_str)
    self.version = version_str
  end

  def satisfies?(constraints)
    self.class.constraint_checker.satisfies?(self.version, constraints)
  end

  def vercmp(v1, v2)
    self.class.vercmp(v1, v2)
  end

  def self.vercmp(v1, v2)
    case
    when comparator.less_than?(v1, v2)    then -1
    when comparator.greater_than?(v1, v2) then 1
    when comparator.equal_to?(v1, v2)     then 0
    else
      raise "v1 (#{v1}) isn't greater than, equal to or less than v2 (#{v2}) ¯\_(ツ)_/¯"
    end
  end

  def self.find_newest_composer_constraint(constraints)
    constraints.reduce([]) do |newest, next_constraints|
      last_constraint = next_constraints.split(/,/).last
      prefix, version = /^([^\d]+)(.*)$/.match(last_constraint)[1..2]
      case vercmp(version, newest[2])
      when -1 then newest
      when  1 then [prefix, version]
      when  0
        prefix == "<=" ? [prefix, version] : newest
      end
    end
  end

  private

  def self.comparator
    ::Composer::Semver::Comparator
  end

  def self.constraint_checker
    ::Composer::Semver::Semver
  end
end
