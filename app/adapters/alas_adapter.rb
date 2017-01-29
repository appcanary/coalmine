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

  generate :package_names do
    # We may need to look into new packages for this. e.g for
    # https://alas.aws.amazon.com/ALAS-2016-669.html the affected packages are
    # "kernel", while we have new packages for a bunch of stuff i.e.
    # perf-debugunfo, kernel-headers, etc. OTOH the remediation is yum update
    # kernel...
    affected_packages
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
              "patched_versions" => [nv.filename],
              # note the lack of release, amazon doesn't really have releases
        }

        arr << DependencyConstraint.parse(h)
      end
      arr
    end
  end

  generate :source_status do
    severity
  end

  generate :criticality do
    case severity
    when "Critical"
      Advisory.criticalities["critical"]
    when "Important"
      Advisory.criticalities["high"]
    when "Medium"
      Advisory.criticalities["medium"]
    when "Low"
      Advisory.criticalities["low"]
    else
      Advisory.criticalities["unknown"]
    end
  end

end
