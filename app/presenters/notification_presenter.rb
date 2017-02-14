class NotificationPresenter
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
  end

  def subject
    pkg_count = notifications_by_package.count
    date_str = @sent_date.strftime("%Y-%m-%d")

    subject = case @type
    when :vuln
      "#{pkg_count} new vulnerable packages (#{date_str})"
    when :patched
      "Fixed: #{pkg_count} patched packages (#{date_str})"
    end

    if !Rails.env.production?
      subject = "[#{Rails.env}] " + subject
    end

    subject
  end

  def should_deliver?
    if Rails.env.production?
      return true
    elsif $rollout.active?(:all_staging_notifications)
      return true
    else
      if @account.email != "hello@appcanary.com"
        return false
      else
        return true
      end
    end
  end

  def notifications_by_package
    @notifications_by_package ||=
      @notifications.group_by(&:package).sort_by { |k, v| [-k.upgrade_priority_ordinal, k.name] }
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
