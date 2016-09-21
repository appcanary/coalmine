class DependencyConstraint
  ATTR = [:release, :package_name, :arch, :patched_versions, 
          :unaffected_versions, :end_of_life, :pending]
  ATTR_MAP = Hash[ATTR.map { |a| [a.to_s, true] }]
  attr_reader *ATTR

  def initialize(hsh)
    hsh.each do |k, v| 
      if v.nil?
        raise ArgumentError.new("Tried to assign nil to #{k}")
      end

      if ATTR_MAP[k] 
        instance_variable_set("@#{k}", v)
      else
        raise ArgumentError.new("Invalid attribute #{k}")
      end
    end

    if @package_name.nil?
      raise ArgumentError.new("Must supply at least a package_name")
    end
  end

  # for testing
  def fetch(k)
    instance_variable_get("@#{k}")
  end

  def [](k)
    fetch(k)
  end
end
