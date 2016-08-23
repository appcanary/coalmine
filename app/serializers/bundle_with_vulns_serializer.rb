class BundleWithVulnsSerializer < ActiveModel::Serializer
  type :monitors
  attributes :name, :vulnerable, :updated_at, :created_at

  has_many :vulnerable_packages
  has_many :vulnerabilities
  
  def vulnerable_packages 
    @vp ||= VulnQuery.from_bundle(object)
  end

  def vulnerabilities
    @vulns ||= vulnerable_packages.map(&:vulnerabilities).flatten
  end

  def vulnerable
    object.vulnerable?
  end
end
