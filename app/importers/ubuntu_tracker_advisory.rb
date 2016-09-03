# TODO: handle references, bugs, etc
class UbuntuTrackerAdvisory < AdvisoryPresenter.new(:candidate, :publicdate, :references, :description, :ubuntu_description, :notes, :bugs, :priority, :discovered_by, :assigned_to, :patches)

  def identifier
    candidate
  end

  def source
    UbuntuTrackerImporter::SOURCE
  end

  def package_platform
    Platforms::Ubuntu
  end

  generate :reported_at do
    DateTime.parse(publicdate).utc
  end

  generate :description do
    if description.present? && description.is_a?(Array)
      description.join(" ")
    end
  end


  generate :criticality do
    priority.downcase
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
