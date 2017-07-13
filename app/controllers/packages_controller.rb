class PackagesController < ApplicationController
  def show
    if current_user.is_admin? && params[:id]
      @package = Package.find(params[:id])
    else

      @package = Package.where(:platform => params[:platform], 
                               :release => params[:release], 
                               :name => params[:name],
                               :version => params[:version]).first!
    end

    @vulns = @package.vulnerabilities.order_by_criticality
    @bundles = @package.bundles.merge(current_account.bundles)
  end
end
