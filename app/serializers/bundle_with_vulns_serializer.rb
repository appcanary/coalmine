class BundleWithVulnsSerializer < ActiveModel::Serializer
  type :monitors
  attributes :name, :vulnerable, :created_at

  has_many :vulnerable_packages, unless: -> { vulnerable_packages.empty? }, :key => "packages", :serializer => PackageSerializer
  has_many :vulnerabilities, unless: -> { vulnerable_packages.empty? }
  
  def vulnerable_packages 
    @vp ||= VulnQuery.from_bundle(object)
  end

  def vulnerabilities
    @vulns ||= vulnerable_packages.map(&:vulnerabilities).flatten.uniq
  end

  def vulnerable
    object.vulnerable_at_all?
  end
end
