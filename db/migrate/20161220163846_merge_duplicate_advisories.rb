class MergeDuplicateAdvisories < ActiveRecord::Migration
  def change
    # For Ubuntu advisories, we use the path as the identifier. Advisories are
    # moved from active/CVE-XXXX-XXXX to retired/CVE-XXXX-XXXX when they are
    # retired. We thus have some duplicate advisories -- the ones that have been
    # retired since Appcanary's importer has been running. New ones are just
    # created for the retired ones.

    # First, let's find all the duplicate advisories
    dupes = Advisory.where(:platform => "ubuntu").joins("inner join advisories a2 on advisories.platform = a2.platform and advisories.reference_ids = a2.reference_ids and advisories.identifier != a2.identifier")

    #Let's make sure the above is true
    active_cves = dupes.select { |a| a.identifier.starts_with? "active" }.map { |a| a.identifier.split('/').second}
    retired_cves = dupes.select { |a| a.identifier.starts_with? "retired" }.map{ |a| a.identifier.split('/').second}

    # Retired has a few old cves where the identifier and the cve don't match, we only care that the actives are a subset of the retired, since we're deleting them
    if !(active_cves.to_set.subset? retired_cves.to_set)
      raise "oops, aborting migration"
    end

    # Okay we can safely delete the active Advisory and Vulnerability
    dupes.each do |adv|
      if adv.identifier.starts_with? "active"
        adv.vulnerabilities.each(&:destroy)
        adv.destroy
      end
    end

    # Now let's change the identifier on existing vulns
    Advisory.where(:platform => "ubuntu").update_all("identifier = regexp_replace(identifier, '(active|retired)\/', '', 'gi')");
  end
end
