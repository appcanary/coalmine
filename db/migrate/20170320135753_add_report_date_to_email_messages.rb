class AddReportDateToEmailMessages < ActiveRecord::Migration
  def change
    add_column :email_messages, :report_date, :date
  end
end
