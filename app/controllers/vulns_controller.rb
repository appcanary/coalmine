class VulnsController < ApplicationController
  def show
    @vuln = Vuln.fake_vulns.first
  end
end
