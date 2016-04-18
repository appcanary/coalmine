class DashboardController < ApplicationController
  def index
    @servers = Server.find_all(current_user)
    @onboarded = @servers.present?

    @silent_servers, @active_servers = @servers.partition(&:gone_silent?)

    if @onboarded
      render :index
    elsif current_user.api_beta
      redirect_to docs_path
    else
      if params[:done]
        @opts = {notice: "Sorry, we can't see your server. Try again in a few moments, or contact us at hello@appcanary.com"}
      end
      redirect_to onboarding_path, @opts || {}
    end
  end
end
