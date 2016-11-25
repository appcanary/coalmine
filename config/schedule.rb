every :monday, :at => "12am" do
  runner "SystemMailer.system_report.deliver_now"
end
