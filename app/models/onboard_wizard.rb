class OnboardWizard
  attr_accessor :user, :servers
  def initialize(user, servers)
    @user = user
    # let's avoid having to make this call
    # several times if we don't have to.
    @servers = servers
  end

  def servers
    @servers ||= Server.find_all(@user)
  end

  def onboarded?
    servers.present?
  end

  def new_user?
    !onboarded?
  end
end
