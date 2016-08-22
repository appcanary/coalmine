class PackageSerializer < ActiveModel::Serializer
  attributes :name, :platform, :release, :version, :upgrade_to

  has_many :vulnerabilities

  class VulnerabilitySerializer < ActiveModel::Serializer
    attributes :title, :description, :cve_ids
  end
end

