class SlackWebhookPatchedSerializer < ActiveModel::Serializer
  attributes :text

  def text
    "Fixed: #{pkg_count} patched packages"
  end

  def pkg_count
    VulnQuery.from_notifications(object.notifications, :patched).group_by(&:package).sort_by { |k, v| [-k.upgrade_priority_ordinal, k.name] }.count
  end
end
