class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token, :require_login, :show_trial_alert

  before_action :require_token

  def require_token
    @current_account = authenticate_or_request_with_http_token do |token, options|
      Account.find_by(token: token)
    end

    @current_account || render_unauthorized
  end

  def render_unauthorized
    render json: {errors: [{title: "Unauthorized"}]}, status: 401
  end

  def current_account
    @current_account
  end
end
