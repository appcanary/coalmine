class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def create
    packages = PackageManager.new(kind, release).parse_list!(params[:packages])
    @pallet = PalletManager.new(current_user).create(params[:pallet])
  end
end
