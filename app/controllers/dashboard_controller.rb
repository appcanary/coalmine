class DashboardController < ApplicationController
  def index
    @servers = Server.find_all(current_user)
    @monitors = Moniter.find_all(current_user)

    wizard = OnboardWizard.new(current_user, @servers)

    if wizard.new_user?
      redirect_to welcome_path
      return
    end

    @silent_servers, @active_servers = @servers.partition(&:gone_silent?)
  end
end
