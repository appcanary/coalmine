class DebianTrackerAdvisory < AdvisoryPresenter.new(:package_name, :cve, :scope, :debianbug, :description, :releases)

  URGENCIES = ["not yet assigned", "unimportant", "end-of-life", "low", "low*", "low**", "medium", "medium*", "medium**", "high", "high*", "high**"]
  URGENCY_RANK = URGENCIES.each_with_index.reduce({}) { |h, (n, i)| h[n] = i; h } 

  # altho data is organized by package and CVE,
  # a CVE can refer to many packages - so can't use it
  # as unique
  def identifier
    "#{cve}-#{package_name}"
  end

  def cve_ids
    [cve]
  end

  def normalize_urgency(str)
    case str
    when "not yet assigned"
      "unknown"
    when "unimportant"
      "negligible"
    when "end-of-life"
      "end-of-life"
    when "low"
      "low"
    when "low*"
      "low"
    when "low**"
      "low"
    when "medium"
      "medium"
    when "medium*"
      "medium*"
    when "medium**"
      "medium"
    when "high"
      "high"
    when "high*"
      "high"
    when "high**"
      "high"
    else
      "unknown"
    end
  end

  def generate_package_info_fields
    if @package_info_fields
      return @package_info_fields
    end

    hsh = {}
    hsh["patched"] = []
    hsh["affected"] = []
    hsh["unaffected"] = []
    hsh["urgencies"] = []

    releases.each_pair do |release, attr|
      hsh["urgencies"] << attr["urgency"]

      case attr["status"]
      when "resolved"
        obj = attr_to_constraint(release, attr) 

        # when they mean 'unaffected' they mark
        # urgency as "unimportant" and fix as 0

        patch, urg = attr.values_at("fixed_version", "urgency")
        if patch == "0" && urg == "unimportant"
          hsh["unaffected"] << obj
        else
          hsh["affected"] << obj
          hsh["patched"] << obj
        end
      when "open"
        hsh["affected"] << attr_to_constraint(release, attr)
      end

      # there is also an 'undetermined', which we ignore
    end

    @package_info_fields = hsh
  end

  # the urgency is set on a per release field. 
  # a cursory glance shows us that they're identical like ~90%
  # of the time, but not always - sometimes its been end of
  # lifed on a given release.
  #
  # that won't do if we want some basic priorities. so,
  # let's hack it. we map the urgencies, get rid of dupes,
  # then pick the most "highly ranked", i.e.
  # ["end-of-lifed", "negligible", "medium", "medium"] 
  # => "medium"
  #
  # (oh and then we normalize them, of course)
  def generate_criticality
    urgencies = generate_package_info_fields["urgencies"].uniq
 
    most_urgent = nil
    if urgencies.size > 1
      most_urgent = urgencies.sort { |x,y| URGENCY_RANK[x] <=> URGENCY_RANK[y] }.last
    else
      most_urgent = urgencies.first
    end

    normalize_urgency(most_urgent)
  end

  def attr_to_constraint(release, attr)
    patch = attr["fixed_version"]
    if patch
      {"release" => release, "package" => package_name, "version" => patch}
    else
      {"release" => release, "package" => package_name }
    end
  end


  def generate_patched
    generate_package_info_fields["patched"]
  end

  def generate_affected
    generate_package_info_fields["affected"]
  end

  def generate_unaffected
    generate_package_info_fields["unaffected"]
  end
 
  def package_platform
    Platforms::Debian
  end

  def source 
    DebianTrackerImporter::SOURCE
  end

  def advisory_keys
    ["identifier", "package_platform", "cve_ids", "patched", "affected", "criticality", "source"]
  end
end
