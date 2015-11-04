class DashboardController < ApplicationController
  def index
    @servers = current_user.servers
    @onboarded = @servers.present?

    @silent_servers, @active_servers = @servers.partition(&:gone_silent?)

    if @onboarded
      render :index
    else
      if params[:done]
        @opts = {notice: "Sorry, we can't see your server. Try again in a few moments, or contact us at hello@appcanary.com"}
      end
      redirect_to onboarding_path, @opts || {}
    end
  end
end
