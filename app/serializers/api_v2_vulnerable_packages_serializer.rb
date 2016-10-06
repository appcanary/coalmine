class ApiV2VulnerablePackagesSerializer < ActiveModel::Serializer
  attributes :name, :kind, :number, :vulnerabilities

  def kind
    object.platform
  end

  def number
    object.version
  end

  def vulnerabilities
    object.vulnerabilities.map { |v|
      ApiV2VulnerabilitiesSerializer.new(v, :upgrade_to => object.upgrade_to)
    }
  end
end

