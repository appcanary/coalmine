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
  mock_attr(:vuln_version) { "3.0.8" }
  mock_attr(:kind) { :ruby }

  def ruby?
    kind == :ruby
  end

  def servers
    apps.collect(&:servers).flatten
  end

  def self.fake_vulns
    [
      Vuln.new({:title => "Ruby on Rails Active Record serialize Helper YAML Attribute Handling Remote Code Execution",
                :description => "Ruby on Rails contains a flaw in the +serialize+ helper in the Active Record.  The issue is triggered when the system is configured to allow users to directly provide values to be serialized and deserialized using YAML.  With a specially crafted YAML attribute, a remote attacker can deserialize arbitrary YAML and execute code associated with it.",
                :criticality => :high,
                :artifact => "activerecord",
                :patch_to => "3.1.0",
                :vuln_version => "3.0.8",}),

      Vuln.new({:title => "Heartbleed",
                  :description => "The Heartbleed bug allows anyone on the Internet to read the memory of the systems protected by the vulnerable versions of the OpenSSL software. This compromises the secret keys used to identify the service providers and to encrypt the traffic, the names and passwords of the users and the actual content. This allows attackers to eavesdrop on communications, steal data directly from the services and users and to impersonate services and users.",

                        :criticality => :critical,
                        :artifact => "openssl",
                        :patch_to => "1.0.1-4ubuntu5.12",
                        :vuln_version => "1.0.1-4ubuntu5.11",}
      
                      )

    ]
  end
end
