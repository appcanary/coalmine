class ApplicationController < ActionController::Base
  impersonates :user

  skip_after_filter :intercom_rails_auto_include
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :require_login, :set_raven_context

  private
  def track_event(user, event)
    if Rails.env.production?
      Analytics.track({
        user_id: user.datomic_id,
        event: event
      })
    end
  end

  def identify_user(user)
    if Rails.env.production?
      Analytics.identify(
        user_id: user.datomic_id,
        traits: {
          email: user.email,
          createdAt: user.created_at,
          name: user.name,
          signup_source: user.beta_signup_source
        })
    end
  end

  def not_authenticated
    redirect_to login_path, alert: "Please login first!"
  end

  def skip_if_logged_in
    if current_user
      redirect_to dashboard_path
    end
  end


  # TODO: test
  unless Rails.env.test?
    before_filter :set_onboarded
    def set_onboarded
      if current_user
        @onboarded = current_user.servers.present?
      end
    end
  end

  def set_raven_context
    Raven.user_context(id: session[:user_id],
                       datomic_id: current_user.try(:datomic_id),
                       email: current_user.try(:email))
    Raven.extra_context(params: params.to_hash, url: request.url)
  end
end
