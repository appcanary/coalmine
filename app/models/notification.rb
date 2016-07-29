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
#

class Notification < ActiveRecord::Base
  belongs_to :email_message
  belongs_to :log_bundle_vulnerability
  belongs_to :log_bundle_patch
end
