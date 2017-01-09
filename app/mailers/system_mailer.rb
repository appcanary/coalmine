class SystemMailer < ActionMailer::Base
  default from: "noreply@appcanary.com"
  layout "mailer"

  def new_subscription_email(user_id)
    @user = User.where(id: user_id).first
    if @user.nil?
      return
    end

    mail(to: "hello@appcanary.com", :subject => "Subscription added by #{@user.email}")
  end

  def subscription_plan_changed(user_id, sub_id)
    @user = User.find_by(id: user_id)
    @sub = SubscriptionPlan.find_by(id: sub_id)
    if @user.nil?
      return
    end
    mail(to: "hello@appcanary.com", :subect => "Subscription changed by #{@user.email}")
  end

  def canceled_subscription_email(user_id)
    @user = User.where(id: user_id).first
    if @user.nil?
      return
    end

    mail(to: "hello@appcanary.com", :subject => "Subscription canceled by #{@user.email}", :body => "")
  end

  def system_report
    env_prefix = ""
    if !Rails.env.production?
      env_prefix = "[#{Rails.env}] "
    end

    @date = 7.days.ago
    @today = Date.today.iso8601

    @user_ct = User.count
    @new_user_ct = User.where("created_at > ?", @date).count

    @active_server_ct = AgentServer.active.count
    @new_server_ct = AgentServer.active.where("created_at > ?", @date).count

    @active_server_bundle_ct = Bundle.via_active_agent.count
    @new_server_bundle_ct = Bundle.via_agent.where("created_at > ?", @date).count

    @monitor_ct = Bundle.via_api.count
    @new_monitor_ct = Bundle.via_api.where("created_at > ?", @date).count

    @new_vuln_ct = Vulnerability.where("created_at > ?", @date).group(:platform).count
    @new_vulns_detected = LogBundleVulnerability.where("created_at > ?", @date).count
    @new_patches_detected = LogBundlePatch.where("created_at > ?", @date).count
    @new_patch_emails_sent = EmailPatched.sent.where("created_at > ?", @date).count
    @new_vuln_emails_sent = EmailVulnerable.sent.where("created_at > ?", @date).count

    @total_revenue = BillingPlan.includes(:subscription_plan, user: :account).map(&:monthly_cost).reduce(&:+)

    mail(to: "hello@appcanary.com", :subject => "#{env_prefix}sysreport #{@today}")
  end

end
