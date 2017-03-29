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
  # nota bene: EDS is used slightly
  # differently from EVuln or EPatched:
  #
  #
  # All EmailMessage descendants are used to log
  # that an email was sent at a particular point in time.
  #
  # The difference is EPatched/EVuln messages are created first
  # then processed later. EDS on the other hand, why bother?
  # we create this as a log at the point we queued up the email
  
  validates :report_date, uniqueness: { scope: :account_id }
end
