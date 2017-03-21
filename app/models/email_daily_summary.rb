# == Schema Information
#
# Table name: email_messages
#
#  id          :integer          not null, primary key
#  account_id  :integer          not null
#  recipients  :string           default("{}"), not null, is an Array
#  type        :string           not null
#  sent_at     :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  report_date :date
#
# Indexes
#
#  index_email_messages_on_account_id  (account_id)
#  index_email_messages_on_sent_at     (sent_at)
#

class EmailDailySummary < EmailMessage

end
