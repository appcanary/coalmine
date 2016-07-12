class PackageSerializer < ActiveModel::Serializer
  attributes :name, :platform, :release, :version

  has_many :vulnerabilities

  class VulnerabilitySerializer < ActiveModel::Serializer
    attributes :title, :patched_versions
  end
end

