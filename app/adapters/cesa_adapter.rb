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

  generate :package_names do
    packages
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
    parcels_by_name = packages.map { |p|
      Parcel::RPM.new(p)
    }.group_by(&:name)

    @packages_to_constraints = parcels_by_name.reduce([]) do |arr, (name, parcels)|
      parcels.each do |p|
        h = { "package_name" => name,
              "arch" => p.arch,
              "release" => normalize_release(p.nevra.release),
              "patched_versions" => [p.filename]
        }

        arr << DependencyConstraint.parse(h)
      end
      arr
    end
  end


  # versions pre el5 are a crapshoot;
  # TODO: there are 20 vulns we need to account for manually from 2011-2014
  def normalize_release(str)
    case str
    when /el7/
      "7"
    when /el6/
      "6"
    when /el5/
      "5"
    when /el4/
      "4"
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
      Advisory.criticalities["critical"]
    when "Important"
      Advisory.criticalities["high"]
    when "Moderate"
      Advisory.criticalities["medium"]
    when "Low"
      Advisory.criticalities["low"]
    else
      Advisory.criticalities["unknown"]
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
