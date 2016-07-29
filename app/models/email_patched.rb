# == Schema Information
#
# Table name: email_messages
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  recipients :string           default("{}"), not null, is an Array
#  type       :string           not null
#  sent_at    :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EmailPatched < EmailMessage
  has_many :notifications, -> { where("log_bundle_patch_id is not null") }, :foreign_key => "email_message_id"
end
