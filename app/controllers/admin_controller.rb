class AdminController < ApplicationController
  skip_before_filter :require_login
  before_filter :require_admin_login
  
  def require_admin_login
    unless current_user && current_user.is_admin?
      not_authenticated
    end
  end
end
