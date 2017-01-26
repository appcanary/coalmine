class OnboardingController < ApplicationController
  def welcome
    @agent_token = current_user ? current_user.token : "<YOUR_TOKEN_HERE>"
    @bundle = BundlePresenter.new(VulnQuery.new(current_account), Bundle.find(726))
  end
end
