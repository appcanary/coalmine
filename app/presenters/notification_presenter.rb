class NotificationPresenter
  delegate :each_pair, to: :notifications_by_vuln
  attr_reader :notifications_by_vuln
  def initialize(type, account, query)
    @type = type
    @account = account
    @notifications = query
    @notifications_by_vuln = @notifications.group_by(&:vulnerability)
  end

  def subject
    note_ct = @notifications_by_vuln.count
    subject = subject_label % note_ct

    if !Rails.env.production?
      subject = "[#{Rails.env}] " + subject
    end

    subject
  end

  def recipients
    recipients = [@account.email]
    if !Rails.env.production?
      if !PREPROD_EMAILS.include?(@account.email)
        recipients = ["hello@appcanary.com"]
      end
    end

    recipients
  end

  def subject_label
    date_str = Time.now.strftime("%Y-%m-%d")
    case @type
    when :vuln
      "%s vulnerabilities detected (#{date_str})"
    when :patched
      "Fixed %s vulnerabilities patched (#{date_str})"
    end
  end
end
