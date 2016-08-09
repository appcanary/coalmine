class DashboardController < ApplicationController
  def index
    @servers = AgentServer.belonging_to(current_user)
    @api_bundles = Bundle.belonging_to(current_user).via_api

    wizard = OnboardWizard.new(current_user, @servers, @api_bundles)

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
