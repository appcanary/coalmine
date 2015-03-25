class Vuln
  include Mocker
  mock_attr(:title) { "Action Mailer Gem for Ruby contains a possible DoS Vulnerability" }
  mock_attr(:notified_at) { Time.now }
  mock_attr(:disclosed_at) { rand(1..36).days.ago }
  mock_attr(:description) { "Action Mailer Gem for Ruby contains a format string flaw in
  the Log Subscriber component. The issue is triggered as format string
  specifiers (e.g. %s and %x) are not properly sanitized in user-supplied
  input when handling email addresses. This may allow a remote attacker
  to cause a denial of service" }
  mock_attr(:criticality) { [:high].sample }
  mock_attr(:osvdb) { "98629" }
  mock_attr(:cve) { "2015-0001" }
  mock_attr(:artifact) { "actionpack" }
  mock_attr(:patch_to) { "2.3.2" }
  mock_attr(:kind) { :ruby }

  def ruby?
    kind == :ruby
  end

  def servers
    apps.collect(&:servers).flatten
  end
end
