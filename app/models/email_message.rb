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

class EmailMessage < ActiveRecord::Base
  belongs_to :account

  scope :unsent, -> { where('sent_at is null') }
end
