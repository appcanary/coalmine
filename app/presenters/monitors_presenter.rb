class MonitorsPresenter
  attr_reader :monitors, :account, :vulnquery

  delegate :any?, :count, :each, :select, to: :monitors
  def initialize(account, collection = nil)
    @account = account
    @vulnquery = VulnQuery.new(account)
    @monitors = collection || @account.bundles.via_api
    @monitors = @monitors.map { |m| BundlePresenter.new(@vulnquery, m) }
  end
end
