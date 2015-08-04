class ApplicationController < ActionController::Base
  impersonates :user

  skip_after_filter :intercom_rails_auto_include
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :require_login

  private
  def not_authenticated
    redirect_to login_path, alert: "Please login first"
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
end
