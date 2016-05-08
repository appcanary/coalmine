class OnboardWizard
  attr_accessor :user, :servers, :monitors

  # we take in servers and monitors explicitly,
  # so we can avoid making multiple API calls
  # in the dashboard
  
  def initialize(user, servers, monitors)
    @user = user
    @servers = servers
    @monitors = monitors
  end

  def onboarded?
    servers.present? || monitors.present?
  end

  def new_user?
    !onboarded?
  end
end
