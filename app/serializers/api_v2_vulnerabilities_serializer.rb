class ApiV2VulnerabilitiesSerializer < ActiveModel::Serializer
  attributes :description, :cve, :criticality, :title, :id
  attribute :unaffected_versions, key: "unaffected-versions"
  attribute :patched_versions, key: "patched-versions"
  attribute :upgrade_to, key: "upgrade-to"

  def cve
    object.reference_ids
  end

  def patched_versions
    object.vulnerable_dependencies.map(&:patched_versions).flatten
  end

  def unaffected_versions
    object.vulnerable_dependencies.map(&:unaffected_versions).flatten
  end

  def upgrade_to
    instance_options[:upgrade_to]
  end

end
