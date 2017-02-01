every :sunday, :at => "17:00" do
  runner "SystemMailer.system_report.deliver_now"
end

every 1.day, :at => "12:00am" do
  runner "SystemMailer.daily_report.deliver_now"
end
