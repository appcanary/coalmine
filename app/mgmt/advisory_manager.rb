# TODO
# 1. test
# 2. abstract
class AdvisoryManager < ServiceManager
  def import!(queuedimport)
    case queuedimport.source
    when "rubysec"
      import_rubysec(queuedimport)
    when "cesa"
      import_cesa(queuedimport)
    else
      raise NotImplementedError.new("Unknown importer source: #{queuedimport.source}")
    end
  end

  def import_rubysec(qi)
    vmger = VulnerabilityManager.new

    Advisory.transaction do
      adv = Advisory.create!(qi.advisory_attributes)
      package_name = adv.package_names.pop

      vuln_mger = VulnerabilityManager.new
      v, error = vuln_mger.create({:advisory_id => adv.id,
                               :package_name => package_name,
                               :package_platform => adv.package_platform,
                               :patched_versions => adv.patched_versions,
                               :unaffected_versions => adv.unaffected_versions})

      if error
        raise ArgumentError.new("Vuln error: #{error}")
      end
    end
  end

  def import_cesa(qi)
    vmger = VulnerabilityManager.new

    Advisory.transaction do
      adv = Advisory.create!(qi.advisory_attributes)
      cesa_create_vulns(adv)
    end
  end

  def cesa_create_vulns(adv)
    vuln_mger = VulnerabilityManager.new
    adv.package_names.each do |pname|
      hsh = {:advisory_id => adv.id,
             :package_name => pname,
             :package_platform => adv.package_platform,
             :patched_versions => cesa_filter_versions(pname, adv.patched_versions)}
      
      vuln, error = vuln_mger.create(hsh)
      
      if error
        raise ArgumentError.new("Vuln error: #{error}")
      end
    end
  end

  def cesa_filter_versions(pname, versions)
    versions.select do |filename|
      filename =~ /#{pname}-[0-9]/
    end
  end
end
