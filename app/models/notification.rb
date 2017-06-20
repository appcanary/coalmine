# == Schema Information
#
# Table name: notifications
#
#  id                          :integer          not null, primary key
#  email_message_id            :integer          not null
#  log_bundle_vulnerability_id :integer
#  log_bundle_patch_id         :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  webhook_id                  :integer
#
# Indexes
#
#  index_notifications_on_email_message_id             (email_message_id)
#  index_notifications_on_log_bundle_patch_id          (log_bundle_patch_id)
#  index_notifications_on_log_bundle_vulnerability_id  (log_bundle_vulnerability_id)
#  index_notifications_on_webhook_id                   (webhook_id)
#

class Notification < ActiveRecord::Base
  belongs_to :email_message
  belongs_to :webhook_message
  belongs_to :log_bundle_vulnerability
  belongs_to :log_bundle_patch
end
