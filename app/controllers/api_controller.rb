class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token, :require_login, :show_trial_alert

  before_action :require_token

  def require_token
    @current_account = authenticate_or_request_with_http_token do |token, options|
      Account.find_by(token: token)
    end

    @current_account || render_unauthorized
  end

  # TODO: standardize with json api
  # TODO: actually make work
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
end
