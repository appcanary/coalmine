class SlackWebhookVulnerableSerializer < ActiveModel::Serializer
  attributes :text

  def text
    "#{pkg_count} new vulnerable packages"
  end

  def pkg_count
    VulnQuery.from_notifications(object.notifications, :vuln).group_by(&:package).sort_by { |k, v| [-k.upgrade_priority_ordinal, k.name] }.count
  end
end
