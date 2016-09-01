# TODO: handle references, bugs, etc
class UbuntuTrackerAdvisory < AdvisoryPresenter.new(:candidate, :publicdate, :references, :description, :ubuntu_description, :notes, :bugs, :priority, :discovered_by, :assigned_to, :patches)

  def identifier
    candidate
  end

  def generate_reported_at
    DateTime.parse(publicdate).utc
  end

  def generate_description
    if description.present? && description.is_a?(Array)
      description.join(" ")
    end
  end

  def generate_criticality
    # ubuntu uses almost the same ones we do.
    case priority
    when "negligible"
      "low"
    else
      # just in case
      priority.downcase
    end
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
        hsh["affected"] << obj
        hsh["patched"] << obj
      when "released"
        hsh["affected"] << obj
        hsh["patched"] << obj
      end
    end

    @package_info_fields = hsh
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
    Platforms::Ubuntu
  end

  def source
    UbuntuTrackerImporter::SOURCE
  end

  def advisory_keys
    ["identifier", "description", "criticality", "package_platform", "patched", "affected", "unaffected", "reported_at", "source"]
  end
end
