class NotificationPresenter
  attr_accessor :notifications_by_vuln, :unpatched_notifications
  def initialize(msg)
    case msg
    when EmailPatched
      @type = :patched
    when EmailVulnerable
      @type = :vuln
    end

    @msg = msg
    @sent_date = msg.created_at

    @account = msg.account
    @notifications = VulnQuery.from_notifications(msg.notifications, @type)

    notifications_by_vuln = {}
    unpatched_notifications = {}

    # TODO: replace with database call,
    # see VulnerableDependency.patchable
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
    subject = subject_label % notification_count

    if !Rails.env.production?
      subject = "[#{Rails.env}] " + subject
    end

    subject
  end

  def notification_count
    @notifications_by_vuln.count + @unpatched_notifications.count
  end

  def notifications_by_package
    @notifications.group_by(&:package).sort_by { |k, v| [k.upgrade_priority_ordinal, k.name] }
  end

  def each_package
    notifications_by_package.each do |pkg, logs|
      yield pkg, sort_and_wrap_logs(logs)
    end
  end

  def recipients
    recipients = [@account.email]
    if !Rails.env.production?
      recipients = ["hello@appcanary.com"]
    end

    recipients
  end

  def subject_label
    date_str = @sent_date.strftime("%Y-%m-%d")
    case @type
    when :vuln
      "%s vulnerabilities detected (#{date_str})"
    when :patched
      "Fixed: %s vulnerabilities patched (#{date_str})"
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

  # TODO:
  # this will all go to shit if bundles were deleted b/w
  # notification trigger and notification processing
  # so maybe we should do something to filter those out? 
  
  # the sorting allows us to effectively "group" bundles on
  # the same server together. if no server present, sort
  # them first! cos its a monitor
  def sort_and_wrap_logs(logs)
    logs.map { |l| LogPresenter.new(l) }.sort_by { |l| l.bundle.try(:agent_server_id) || 0 }
  end

  class LogPresenter
    def initialize(log)
      @log = log
    end

    def has_server?
      @log.bundle.try(:agent_server)
    end

    def bundle
      @log.bundle
    end

    def server
      @log.bundle.try(:agent_server)
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
