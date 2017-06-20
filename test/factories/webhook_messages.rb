# == Schema Information
#
# Table name: webhook_messages
#
#  id         :integer          not null, primary key
#  account_id :integer
#  webhook_id :integer
#  url        :string
#  type       :string
#  sent_at    :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_webhook_messages_on_account_id  (account_id)
#  index_webhook_messages_on_webhook_id  (webhook_id)
#

FactoryGirl.define do
  factory :webhook_message do
    account nil
account ""
webhook ""
url ""
type ""
sent_at "2017-06-19 16:38:44"
  end

end
