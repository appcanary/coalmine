class NotificationMailer < ActionMailer::Base
  default from: "Appcanary <hello@appcanary.com>"
  layout 'mailer'

  def vulnerable_email(msg)
    @lbvs = LogBundleVulnerability.where("id in (#{msg.notifications.select("log_bundle_vulnerability_id").to_sql})").includes(:package, :vulnerable_dependency, :vulnerability)
    mail(to: "hello@appcanary.com", :subject => "Appcanary U R VULN LOL")
  end

  def patched_email(msg)
    @lbps = LogBundlePatch.where("id in (#{msg.notifications.select("log_bundle_patch_id").to_sql})").includes(:package, :vulnerable_dependency, :vulnerability)
    mail(to: "hello@appcanary.com", :subject => "Appcanary Patched!")
  end

end

