class RubysecMailer < ActionMailer::Base
  default from: "rubysec <noreply@appcanary.com>"
  layout 'mailer'

  def new_advisory(advisory_id)
    @advisory = RubysecAdvisory.find(advisory_id)

    mail(to: "info@rubysec.com", :subject => "New Rubysec submission") do |format|
      format.text
    end
  end
end
