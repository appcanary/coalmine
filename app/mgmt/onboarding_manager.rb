class OnboardingManager
  attr_reader :user, :account
  def initialize(user)
    @user = user
    @account = user.account
  end

  def tried_product?
    self.account.agent_servers.count > 0 || self.account.monitors.count > 0 || self.account.check_api_calls.count > 0
  end
end
