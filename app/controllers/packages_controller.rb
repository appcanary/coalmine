class PackagesController < ApplicationController
  def show
    @packages = Package.where(:platform => params[:platform], 
                  :release => params[:release], 
                  :name => params[:name],
                             )
    if @packages.empty?
      raise ActiveRecord::RecordNotFound
    end
    @release = params[:release]
    @platform = params[:platform]
    @package = @packages.first
    @vulns = @packages.vulnerabilities
  end
end
