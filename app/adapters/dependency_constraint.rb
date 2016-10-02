class DependencyConstraint
  ATTR = [:release, :package_name, :arch, :patched_versions, 
          :unaffected_versions, :end_of_life, :pending]
  ATTR_MAP = Hash[ATTR.map { |a| [a.to_s, true] }]

  def self.parse(hsh)
    attributes = {}

    hsh.each do |k, v| 
      if v.nil?
        raise ArgumentError.new("Tried to assign nil to #{k}")
      end

      if ATTR_MAP[k] 
        attributes[k] = v
      else
        raise ArgumentError.new("Invalid attribute #{k}")
      end
    end

    if attributes["package_name"].nil?
      raise ArgumentError.new("Must supply at least a package_name")
    end

    hsh
  end
end
