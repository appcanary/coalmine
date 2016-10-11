class NotificationPresenter
  def initialize(type, account, query)
    @type = type
    @account = account
    @notifications = query

    notifications_by_vuln = {}
    unpatched_notifications = {}

    # separate chaff from wheat
    @notifications.each do |note|
      if !note.package.upgrade_to.any?
        unpatched_notifications[note.vulnerability] ||= []
        unpatched_notifications[note.vulnerability] << note
      else
        notifications_by_vuln[note.vulnerability] ||= []
        notifications_by_vuln[note.vulnerability] << note 
      end
    end

    @unpatched_notifications = unpatched_notifications
    @notifications_by_vuln = notifications_by_vuln
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

  def each_vuln
    @notifications_by_vuln.each_pair do |vuln, logs|
      yield vuln, sort_and_wrap_logs(logs)
    end
  end

  def has_unpatched_vulns?
    @unpatched_notifications.present?
  end

  def each_unpatched_vuln
    @unpatched_notifications.each_pair do |vuln, logs|
      yield vuln, sort_and_wrap_logs(logs)
    end
  end

  def sort_and_wrap_logs(logs)
    logs.sort { |l| l.bundle.agent_server_id }.map { |l| LogPresenter.new(l) }
  end

  class LogPresenter
    def initialize(log)
      @log = log
    end

    def has_server?
      @log.bundle.agent_server
    end

    def bundle
      @log.bundle
    end

    def server
      @log.bundle.agent_server
    end

    def package_name
      @log.package.name
    end

    def current_version
      @log.package.version
    end

    def upgrade_to
      @log.package.upgrade_to
    end
  end
end
