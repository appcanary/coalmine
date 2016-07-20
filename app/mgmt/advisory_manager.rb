# TODO
# 1. test
# 2. abstract
# 3. idempotent import
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

    vuln = nil
    Advisory.transaction do
    adv = Advisory.create!(qi.advisory_attributes)
    hsh = adv.vuln_attr

    package_name = adv.package_names.pop
    hsh = hsh.merge({ 
      "patched_versions" => {package_name => adv.patched_versions},
      "unaffected_versions" => {package_name => adv.unaffected_versions}})

    vuln_mger = VulnerabilityManager.new
    vuln, error = vuln_mger.create(hsh)

    if error
      raise ArgumentError.new("Vuln error: #{error}")
    end
    adv.vulnerabilities << vuln
    end
    vuln
  end

  def import_cesa(qi)
    vmger = VulnerabilityManager.new

    adv = Advisory.create!(qi.advisory_attributes)
    cesa_create_vulns(adv)
  end

  def cesa_create_vulns(adv)
    vuln_mger = VulnerabilityManager.new

    packages = adv.patched_versions.map do |pv|
      RPM::Nevra.new(pv)
    end.group_by(&:name)


    hsh = adv.vuln_attr
    hsh["package_names"] = packages.keys
    hsh["patched_versions"] = {}

    packages.each do |name, pkgs|
      hsh["patched_versions"][name] = pkgs.map(&:filename)
    end

    vuln, error = vuln_mger.create(hsh)

    if error
      raise ArgumentError.new("Vuln error: #{error}")
    end

    adv.vulnerabilities << vuln
    vuln
  end

end
