class UbuntuTrackerAdapter < AdvisoryAdapter.new(:candidate, :publicdate, :publicdateatusn, :crd, :references, :description, :ubuntu_description, :notes, :bugs, :priority, :discovered_by, :assigned_to, :patches, :filepath)

  def identifier
    candidate
  end

  def source
    UbuntuTrackerImporter::SOURCE
  end

  def platform
    UbuntuTrackerImporter::PLATFORM
  end

  generate :reference_ids do
    [candidate]
  end

  generate :title do
    candidate
  end

  # From: ubuntu-cve-tracker/README
  # MITRE is the definitive CVE database, but NVD contains the same information,
  # updates their database more frequently and also lists the PublicDate. Using
  # the above schedule allows our database to stay up-to-date with the NVD, and
  # ensure that our descriptions are also up to date. For CVEs where the
  # PublicDate is wrong, we can override the value using the "CRD" field
  # instead.

  # Since we want to keep a record of what the PublicDate was when the USN
  # published, USN publication should include the addition of the
  # "PublicDateAtUSN" field, which duplicates PublicDate, in case it changes
  # later. When answering the question "When did a CVE go public?" the scripts
  # will use CRD over PublicDateAtUSN over PublicDate. Times should include the
  # timezone; UTC is preferred. If no time is specified during coordination,
  # 14:00:00 UTC is recommended.
  # Eg: PublicDateAtUSN: 2009-03-27 23:45:00 UTC

  generate :reported_at do
    reported_at = crd || publicdateatusn || publicdate
    if reported_at && reported_at != "unknown"
      DateTime.parse(reported_at).utc
    else
      nil
    end
  end

  generate :description do
    if description.present? && description.is_a?(Array)
      description.join(" ")
    end
  end

  generate :source_status do
    priority
  end

  generate :criticality do
    case priority
    when /negligible/i
      :negligible
    when /low/i
      :low
    when /medium/i
      :medium
    when /high/i
      :high
    when /critical/i
      :critical
    else
      :unknown
    end
  end

  generate :related do
    rel = []
    if references
      rel << references
    end

    if bugs
      rel << bugs
    end

    rel.flatten.compact
  end

  generate :constraints do
    pat = generate_package_info_fields["patched"].map do |p|
      h = p.dup
      if h["status"] == "pending"
        h["pending"] = true
      end

      if h["version"]
        h["patched_versions"] = h["version"].split(",").map(&:strip)
      end

      DependencyConstraint.parse(h.except("status", "version"))
    end


    aff = generate_package_info_fields["affected"].map do |a|
      h = a.dup
      if h["version"] =~ /end-of-life/
        h["end_of_life"] = true
      end
       
      DependencyConstraint.parse(h.except("status", "version"))
    end

    pat + aff
  end

  def generate_package_info_fields
    # cache
    if @package_info_fields
      return @package_info_fields
    end

    hsh = {}
    hsh["patched"] = []
    hsh["affected"] = []
    hsh["unaffected"] = []

    self.patches ||= []

    patches.each do |obj|
      case obj["status"]
      when "needs-triage"
        # do nothing
      when "not-affected"
        hsh["unaffected"] << obj
      when "DNE"
        hsh["unaffected"] << obj

      when "needed"
        hsh["affected"] << obj
      when "active"
        hsh["affected"] << obj
      when "deferred"
        hsh["affected"] << obj

      when "pending"
        hsh["patched"] << obj
      when "released"
        hsh["patched"] << obj
      end
    end

    @package_info_fields = hsh
  end

  generate :patched do
    generate_package_info_fields["patched"]
  end

  generate :affected do
    generate_package_info_fields["affected"]
  end

  generate :unaffected do
    generate_package_info_fields["unaffected"]
  end
end
