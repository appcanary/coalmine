class RubysecController < ApplicationController
  skip_before_filter :require_login
  before_action -> { @skiptopbar = true }

  def preview
    @advisory = RubysecAdvisory.new(advisory_params)
    @preview = @advisory.generate_yaml
    @submit = true
  end

  def create
    @advisory = RubysecAdvisory.new(advisory_params)

    unless @advisory.save
      @submit = true
      render :preview
    end
  end

  def advisory_params
    params.require(:rubysec_advisory).
      permit(:gem, :framework, :platform, 
             :cve, :url, :title, 
             :date, :description, :cvss_v2, 
             :cvss_v3, :unaffected_versions, 
             :patched_versions, :submitter_email)
  end
end
