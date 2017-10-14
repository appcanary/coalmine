class AgentBundlesSerializer < ActiveModel::Serializer
  type :monitors
  attributes :name, :path, :vulnerable, :created_at

  has_many :vulnerable_packages, unless: -> { vulnerable_packages.empty? }, :key => "packages", :serializer => PackageSerializer
  has_many :vulnerabilities, unless: -> { vulnerable_packages.empty? }
  
  def vulnerable_packages
    if instance_options[:hide_ignored]
      vq = VulnQuery.new(object.account)
      @vp ||= vq.from_bundle(object)
    else
      @vp ||= VulnQuery.affected_from_bundle(object)
    end
  end

  def vulnerabilities
    @vulns ||= vulnerable_packages.map(&:vulnerabilities).flatten.uniq
  end

  def vulnerable
    object.vulnerable?
  end
end

