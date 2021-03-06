class ApplicationController < ActionController::Base
  impersonates :user

  skip_after_filter :intercom_rails_auto_include
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :require_login, :set_raven_context, :show_trial_alert, :show_acquired


  # nominally meant for the ErrorsController,
  # Rails tries hard to prevent you from calling another
  # controller's action. In order to have errors show properly,
  # without a redirect, simplest solution was to just place
  # these methods here - so they can be called from *any*
  # controller, i.e. see the above rescue_from
  # these can't be private, btw, since we route to them
  # inside routes.rb
  #
  # Rails has some mechanism for catching 
  # ActiveRecord::NotFounds and, coupled with making the router
  # the config.exceptions_app middleware as defined in
  # config.rb, is also "smart" enough to know that is a 404.
  #
  # Barring spending another hour tracking down that code, so
  # I can properly intercept it - and maybe make a blog post -
  # this solution shall suffice.
  def error_not_found
    render "errors/not_found", :layout => 'launchrock', :status => 404
  end

  def error_unacceptable
    render "errors/not_found", :layout => 'launchrock', :status => 422
  end

  def error_internal_error
    render "errors/internal_error", :layout => 'launchrock', :status => 500
  end

  def show_trial_alert
    if current_user && !current_user.has_billing? && !current_user.is_admin?

      user_has_tried_product = OnboardingManager.new(current_user).tried_product?

      if user_has_tried_product
        if current_user.trial_remaining < 0
          flash.now[:error] = "Your trial has expired :( Please add a <a href='#{billing_path}'>add a credit card</a> to continue service.".html_safe
        elsif current_user.trial_remaining < 7
          flash.now[:notice] = "You have #{current_user.trial_remaining} remaining days on your trial. Don't forget to <a href='#{billing_path}'>add a credit card!</a>".html_safe
        else
          flash.now[:notice] = "You have #{current_user.trial_remaining} remaining days on your trial. Don't forget to <a href='#{billing_path}'>add a credit card!</a>".html_safe
        end
      end
    end
  end

  def current_account
    if current_user
      current_user.account
    end
  end

  def show_acquired
    if $rollout.active?(:acquired)
      flash[:error] = ACQUIRED_TEXT
    end
  end

  private
  def not_authenticated
    redirect_to login_path, alert: "Please login first!"
  end

  def skip_if_logged_in
    if current_user
      redirect_to dashboard_path
    end
  end

  def set_raven_context
    Raven.user_context(id: session[:user_id],
                       email: current_user.try(:email))
    Raven.extra_context(params: params.to_hash, url: request.url)
  end

end
