class OnboardingController < ApplicationController
  def welcome
    @agent_token = current_user ? current_user.token : "<YOUR_TOKEN_HERE>"
  end
end
