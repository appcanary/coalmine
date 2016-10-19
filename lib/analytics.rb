class Analytics
  class_attribute :backend

  if Rails.env.production?
    self.backend = Segment::Analytics
  else
    require_relative "helpers/fake_analytics_backend"
    self.backend = FakeAnalyticsBackend
  end

  def initialize(key)
    @segment = backend.new({
      write_key: key,
      on_error: Proc.new { |status, msg| print msg }
    })
  end

  def track_event(account, event, properties = {})
    hsh = {
      user_id: account.analytics_id,
      event: event
    }

    if properties.present?
      hsh[:properties] = properties
    end

    @segment.track(hsh)
  end

  # used in users contorller
  def identify_user(user)
    account = user.account
    @segment.identify(
      user_id: account.analytics_id,
      traits: {
        email: account.email,
        createdAt: account.created_at,
        name: user.name,
        signup_source: user.beta_signup_source
      })
  end

  def track_user(account)
    @segment.identify(
      user_id: account.analytics_id,
      traits: {
        email: account.email,
        "server-count": account.agent_servers.count,
        "active-server-count": account.active_servers.count,
        "monitored-app-count": account.api_bundles.count,
        "api-calls-count": account.check_api_calls.count
      })
  end

  # users controller
  def new_signup(user)
    identify_user(user)
    track_event user.account, "Signed Up"
  end

  # user_sessions controller
  def logged_in(user)
    track_event user.account, "Logged In"
  end

  # user_sessions controller
  def logged_out(user)
    track_event user.account, "Logged Out"
  end

  # billing controller
  def added_credit_card(user)
    track_event user.account, "Added credit card"
  end
  
  # billing controller
  def canceled_subscription(user)
    track_event user.account, "Canceled subscription"
  end

  # added in mailer
  def track_notification(account, type)
    event = case type
            when :vuln
              "Got Vulnerability Notification"
            when :patched
              "Got Fixed Notification"
            end

    track_event(account, event)
  end

  # added in agent controller
  def added_server(account, server)
    track_user(account)
    track_event account, "Added Server", server_attributes(server)
  end

  # added in both agent & api server controllers
  def deleted_server(account, server)
    track_user(account)
    track_event account, "Deleted Server", server_attributes(server)
  end

  # added in bundle manager
  def added_bundle(account, bundle)
    track_user(account)
    track_event account, "Added App", bundle_attributes(bundle)
  end

  # added in bundle manager
  def updated_bundle(account, bundle)
    track_user(account)
    track_event account, "Updated App Artifacts", bundle_attributes(bundle)
  end

  # added in bundle manager
  def deleted_bundle(account, bundle)
    track_user(account)
    track_event account, "Deleted App", bundle_attributes(bundle)
  end

  # added to api controller
  def track_api_call(account)
    track_user(account)
    track_event account, "Made API Call"
  end

  def vuln_attributes(vuln)
    vuln.slice("id", "title")
  end

  def bundle_attributes(bundle)
    bundle.attributes.slice("id", "platform", "release")
  end

  def server_attributes(server)
    server.attributes.slice("id", "distro", "release", "agent_release_id")
  end

end
