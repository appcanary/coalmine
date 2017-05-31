class MonitorsPresenter
  attr_reader :monitors, :account, :vulnquery

  delegate :any?, :count, :each, :select, to: :monitors
  def initialize(account, vulnquery)
    @account = account
    @vulnquery = vulnquery
    scope = @vulnquery.bundles_with_vulnerable_scope
    @monitors = @account.send(scope).via_api.map { |m| BundlePresenter.new(@vulnquery, m) }
  end
end
