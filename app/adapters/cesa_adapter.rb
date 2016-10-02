class CesaAdapter < AdvisoryAdapter.new(:cesa_id, :issue_date, :synopsis, 
                                        :severity, :os_arches, :os_releases, 
                                        :references, :packages)

  def identifier
    @gen_cesa_id ||= cesa_id.gsub("--", ":")
  end

  def platform
    CesaImporter::PLATFORM
  end

  def source
    CesaImporter::SOURCE
  end

  generate :reference_ids do
    [identifier.gsub("CESA", "RHSA")]
  end

  generate :patched do
    packages.map { |p|
      {"filename" => p}
    }
  end

  generate :constraints do 
    nevras_by_name = packages.map { |p|
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


  # versions pre el7 are a crapshoot;
  # most but not all el6 and el5 is a ???
  def normalize_release(str)
    case str
    when /el7/
      "7"
    when /el6/
      "6"
    else
      "unknown"
    end
  end


  generate :affected do
    os_arches.map do |arch|
      os_releases.map do |rel|
        {"arch" => arch, "release" => rel}
      end
    end.flatten
  end

  generate :criticality do
    case severity
    when "Critical"
      "critical"
    when "Important"
      "high"
    when "Moderate"
      "medium"
    when "Low"
      "low"
    else
      "unknown"
    end
  end

  generate :source_status do
    severity
  end

  generate :title do
    synopsis
  end

 
  generate :reported_at do
    issue_date
  end

  generate :related do
    references
  end
end
