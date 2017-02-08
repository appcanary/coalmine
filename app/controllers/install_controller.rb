class InstallController < ApplicationController
  skip_before_filter :require_login, :only => [:deb, :conf]

  def deb
    if params[:api_key].present?
      validate_token(params[:api_key])
    end
    @api_key = params[:api_key]
  end

  def conf
    if params[:api_key].present?
      validate_token(params[:api_key])
    end
    @api_key = params[:api_key]
    @platform_supported = Platforms.supported?(params[:platform])
    respond_to do |format|
      format.conf do
        if params[:pkg_type] == "deb"
          render "deb.conf"
        elsif prams[:pkg_type] == "rpm"
          render "rpm.conf"
        else
          #Router should only allow deb or rpm, but render deb here in case we somehow get here
          render "deb.conf"
        end
      end
    end

  end

  def validate_token(token)
    account = Account.find_by(token: token)
    if !account
      render_unauthorized
    end
  end



  def render_unauthorized
    # This is probably going to be piped to sudo bash so we should be careful
    respond_to do |format|
      format.sh do
        send_data "echo \"Unauthorized: Invalid Token\"", status: 401, type: "text/x-shellscript", disposition: :inline
      end
    end
  end
end
