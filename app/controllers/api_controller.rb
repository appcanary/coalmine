class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token, :require_login, :show_trial_alert

  before_action :require_token

  def require_token
    @current_account = authenticate_with_http_token do |token, options|
      Account.find_by(token: token)
    end

    @current_account || render_unauthorized
  end

  def render_unauthorized
    render json: {errors: [{title: "Unauthorized"}]}, status: 401
  end

  def errors_to_h(errors)
    return if errors.nil?

    json = {}
    new_hash = errors.to_hash(true).map do |k, v|
      v.map do |msg|
        {title: msg }
      end
    end.flatten
    json[:errors] = new_hash
    json
  end

  def current_account
    @current_account
  end

  def register_api_call!
    $analytics.track_api_call(current_account)
    current_account.log_api_calls.create!(:action => "#{controller_name}/#{action_name}", :platform => params[:platform], :release => params[:release])
  end

  def v2_request?
    request.path.index("/api/v2") == 0
  end
end
