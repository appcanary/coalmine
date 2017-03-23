class VulnerabilitiesDataTablesSerializer < ActiveModel::Serializer
  attributes :draw, :recordsTotal, :recordsFiltered, :data

  def draw
    @instance_options[:draw]
  end

  def recordsTotal
    @instance_options[:total_count]
  end

  def recordsFiltered
    @instance_options[:filtered_count]
  end

  def data
    @object.map do |vuln|

      { platform: scope.platform_icon(vuln.platform),
        criticality: scope.criticality_icon(vuln.criticality),
        title: scope.link_to(vuln.title, scope.vuln_path(vuln), target: "_blank"),
        cves: cves(vuln),
        reported_at: vuln.reported_at.try(:strftime, "%Y-%m-%d"),
        packages: package_names(vuln)
       }
    end
  end

  private
  def package_names(vuln)
    # we have this in the vuln presenter, but I don't want to instantiate the extra object
    # also it seems that the fasted way to do this is to do one includes query
    package_names = vuln.vulnerable_dependencies.map(&:package_name).sort.uniq #package_names
    if package_names.size > 2
      package_names = package_names.take(2) << "&#8230;"
    end

    package_names.join(", ")
  end

  def cves(vuln)
    cves = vuln.reference_ids.select { |s| s =~ /CVE/ }
    if cves.size > 3
      cves = cves.take(3) << "&#8230;"
    end

    cves.join(", ")

  end
end
