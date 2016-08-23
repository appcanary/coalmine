class PackageSerializer < ActiveModel::Serializer
  attributes :name, :platform, :release, :version, :upgrade_to

  has_many :vulnerabilities
end
