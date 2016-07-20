class PackageSerializer < ActiveModel::Serializer
  attributes :name, :platform, :release, :version, :upgrade_to

  has_many :vulnerabilities

  def upgrade_to
    binding.pry
  end

  class VulnerabilitySerializer < ActiveModel::Serializer
    attributes :title, :patched_versions
  end
end

