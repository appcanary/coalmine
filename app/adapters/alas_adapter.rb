class AlasAdapter < AdvisoryAdapter.new(:alas_id, :reference_ids, :severity, 
                                        :released_at, :description, :affected_packages, 
                                        :remediation, :new_packages)

  def identifier
    alas_id
  end

  def platform
    AlasImporter::PLATFORM
  end

  def source
    AlasImporter::SOURCE
  end

  generate :title do
    identifier
  end

  generate :description do
    description
  end

  generate :reference_ids do
    reference_ids
  end

  generate :reported_at do
    DateTime.parse(released_at).utc
  end

  generate :remediation do
    remediation
  end

  generate :patched do
    new_packages.map { |p|
      {"filename" => p}
    }
  end

  generate :affected do
    affected_packages.each do |p|
      {"package_name" => p }
    end
  end

  generate :constraints do 
    nevras_by_name = new_packages.map { |p|
      nevra = RPM::Nevra.new(p)
    }.group_by(&:name)

    @packages_to_constraints = nevras_by_name.reduce([]) do |arr, (name, nevras)|
      nevras.each do |nv|
        h = { "package_name" => name,
              "arch" => nv.arch,
              "release" => normalize_release(nv.release),
              "patched_versions" => [nv.filename]
        }

        arr << DependencyConstraint.parse(h)
      end
      arr
    end
  end

  #amazon doesn't really have releases?

  def normalize_release(str)
    case str
    when /amzn1/
      "amazn1"
    else
      str
    end
  end

  generate :source_status do
    severity
  end

  generate :criticality do
    case severity
    when "Critical"
      "critical"
    when "Important"
      "high"
    when "Medium"
      "medium"
    when "Low"
      "low"
    else
      "unknown"
    end
  end

end
