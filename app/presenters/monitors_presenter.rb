class MonitorsPresenter
  attr_reader :monitors, :account, :vulnquery

  delegate :any?, :count, :each, :select, to: :monitors
  def initialize(account, vulnquery, collection = nil)
    @account = account
    @vulnquery = vulnquery
    @monitors = collection || @account.bundles.via_api
    @monitors = @monitors.map { |m| BundlePresenter.new(@vulnquery, m) }
  end
end
