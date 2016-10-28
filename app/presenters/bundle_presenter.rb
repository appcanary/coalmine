class BundlePresenter
  attr_reader :vulnquery, :bundle
  delegate :id, :to_param, :display_name,
    :platform, :packages, :created_at, :to => :bundle
  def initialize(vq, mon)
    @vulnquery = vq
    @bundle = mon
  end

  def vulnerable?
    vulnquery.vuln_bundle?(bundle)
  end

  def vuln_packages
    vulnquery.from_bundle(bundle)
  end
end
