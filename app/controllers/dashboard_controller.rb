class DashboardController < ApplicationController
  def index
    @servers = Server.find_all(current_user)
    @monitors = Moniter.find_all(current_user)

    wizard = OnboardWizard.new(current_user, @servers, @monitors)

    # TODO: in the future, keep track of whether ppl
    # have seen a given page before, be more intelligent
    if wizard.new_user?
      if params[:done]
        flash[:notice] = "Did you try adding a server or a monitor? We don't see it yet. Double check your settings, and refresh this page - or contact us for support: hello@appcanary.com"
      end
      redirect_to onboarding_path
      return
    end

    @silent_servers, @active_servers = @servers.partition(&:gone_silent?)
  end
end
