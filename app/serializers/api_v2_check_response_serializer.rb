class ApiV2CheckResponseSerializer < ActiveModel::Serializer
  attributes :data, :vulnerable

  def data
    object.map do |vuln_pkg|
      { "type" => "artifact-version",
        "attributes" => ApiV2VulnerablePackagesSerializer.new(vuln_pkg)
      }
    end
  end

  def vulnerable
    if object.present?
      true
    else
      false
    end
  end
end
