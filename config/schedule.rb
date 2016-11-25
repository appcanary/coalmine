every :sunday, :at => "17:00" do
  runner "SystemMailer.system_report.deliver_now"
end
