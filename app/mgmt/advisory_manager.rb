# TODO
# 1. test
# 2. abstract
# 3. idempotent import
require 'rpm'
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
      hsh = adv.to_vuln_attributes

      vds = adv.package_names.map do |name|
        {
          :package_name => name,
          :patched_versions => adv.patched_versions,
          :unaffected_versions => adv.unaffected_versions
        }
      end

      vuln_mger = VulnerabilityManager.new(adv.package_platform)
      vuln, error = vuln_mger.create(adv.to_vuln_attributes, vds)

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
    
    vuln_mger = VulnerabilityManager.new(adv.package_platform)

    packages = adv.patched_versions.map do |pv|
      RPM::Nevra.new(pv)
    end.group_by(&:name)


    hsh = adv.to_vuln_attributes

    vds = packages.each_pair.map do |name, pkgs|
      {
        :package_name => name,
        :affected_releases => adv.affected_releases,
        :affected_arches => adv.affected_arches,
        :patched_versions => pkgs.map(&:filename)
      }
    end

    vuln = nil
    Advisory.transaction do
      vuln, error = vuln_mger.create(hsh, vds)

      if error
        raise ArgumentError.new("Vuln error: #{error}")
      end

      adv.vulnerabilities << vuln
    end
    vuln
  end

end
