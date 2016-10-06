class ApiV2MonitorSerializer < ActiveModel::Serializer
  attributes :id, :name, :kind, :vulnerable
  attribute :created_at, key: "created-at"
  has_many :vulnerable_versions, if: -> { instance_options[:show_action] }, key: "vulnerable-versions"

  def kind
    object.platform
  end

  def vulnerable
    object.vulnerable?
  end

  def vulnerable_versions
    @vp ||= VulnQuery.from_bundle(object)
    @vp.map do |vuln_pkg|
      { 
        "type" => "artifact-version",
        "id" => vuln_pkg.id,
        "attributes" => ApiV2VulnerablePackagesSerializer.new(vuln_pkg)
      }
    end
  end
end
