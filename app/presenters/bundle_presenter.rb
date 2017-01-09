class BundlePresenter
  attr_reader :vulnquery, :bundle
  delegate :id, :to_param, :display_name,
    :platform, :created_at, :updated_at, :to => :bundle
 
  def initialize(vq, mon)
    @vulnquery = vq
    @bundle = mon
  end

  def vulnerable?
    @vulnerable_q ||= Rails.cache.fetch("#{bundle.cache_key}/vulnerable?") do
      vulnquery.vuln_bundle?(bundle)
    end
  end

  def criticalities
    #TODO: I can't use vuln_packages here because we call to_a on it. Why?
    @criticalities ||= Rails.cache.fetch("#{@bundle.cache_key}/criticalities") do
      vulnquery.from_bundle(bundle).map { |p| p.vulnerabilities.max_criticality_ordinal}
        .inject(Hash.new(0)) { |tot, c| tot[c] += 1; tot }
    end
  end

  def criticalities_order
    # string to sort by from a map of criticalities
    BundlePresenter.criticalities_order(self.criticalities)
  end

  def vuln_packages
    # @phillmv why id we call to_a here?
    @vuln_packages ||= Rails.cache.fetch("#{@bundle.cache_key}/vuln_packages") do
      vulnquery.from_bundle(@bundle).sort_by { |p| [-p.vulnerabilities.max_criticality_ordinal, p.name]}.to_a
    end
  end

  def all_packages
    # @phillmv why did we call to_a here?
    @all_packages ||= bundle.packages.order(:name).to_a
  end

  def ignored_package_logs
    @ignored_packages ||= bundle.log_resolutions.select("count(log_resolutions.vulnerable_dependency_id) vuln_count", :user_id, :package_id, :note).group(:package_id, :user_id, :note).includes(:package, :user).to_a
  end

  def self.criticalities_order(criticalities)
    Vulnerability.criticalities.values.sort.reverse.map do |ordinal|
      criticality = criticalities[ordinal].present? ? criticalities[ordinal] : 0
      criticality.to_s.rjust(5, '0')
    end.join(".")
  end
end
