class ApiV2CheckResponseSerializer < ActiveModel::Serializer
  attributes :data, :vulnerable, :meta

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

  def meta
    {deprecated: "This endpoint is no longer supported."}
  end
end
