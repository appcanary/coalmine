class MonitorsPresenter
  attr_reader :monitors, :account, :vulnquery

  delegate :any?, :count, :each, :select, to: :monitors
  def initialize(account, vulnquery)
    @account = account
    @vulnquery = vulnquery
    bundles = @account.bundles.via_api
    vuln_hsh = @vulnquery.vuln_hsh(bundles)
    @monitors = bundles.map { |m| BundlePresenter.new(@vulnquery, m, vuln_hsh[m.id]) }
  end
end
