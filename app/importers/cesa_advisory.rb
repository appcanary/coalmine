class CesaAdvisory < AdvisoryPresenter.new(:cesa_id, :issue_date, :synopsis, 
                                           :severity, :os_arches, :os_releases, 
                                           :references, :packages)

  def identifier
    @gen_cesa_id ||= cesa_id.gsub("--", ":")
  end

  def package_platform
    Platforms::CentOS
  end

  def source
    CesaImporter::SOURCE
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
        arr <<
        { "package_name" => name,
          "arch" => nv.arch,
          "release" => normalize_release(nv.release),
          "patched_versions" => [nv.filename]
        }
      end
      arr
    end
  end


  # versions pre el7 are a crapshoot;
  # most but not all el6 and el5 is a ???
  def normalize_release(str)
    case str
    when /el7/
      "el7"
    when /el6/
      "el6"
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
