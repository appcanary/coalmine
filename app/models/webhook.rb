# == Schema Information
#
# Table name: webhooks
#
#  id         :integer          not null, primary key
#  account_id :integer
#  url        :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_webhooks_on_account_id  (account_id)
#

class Webhook < ActiveRecord::Base
  belongs_to :account
end
