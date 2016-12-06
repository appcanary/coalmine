class PackagesController < ApplicationController
  def show
    @package = Package.where(:platform => params[:platform], 
                  :release => params[:release], 
                  :name => params[:name],
                  :version => params[:version]).first!

    @vulns = @package.vulnerabilities.order(criticality: :desc)
  end
end
