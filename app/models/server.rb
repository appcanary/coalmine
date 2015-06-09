class Server < CanaryBase
  attr_accessor :apps, :last_heartbeat, :ip, :name, :hostname, :uname, :id, :uuid

  # include Mocker

  # mock_attr(:id) { 1 }
  # mock_attr(:name) { Faker::Lorem.word }
  # mock_attr(:active_issues) { [] }
  # mock_attr(:last_synced_at) {  rand(120).minutes.ago }
  # mock_attr(:rubygems) { 34 }
  # mock_attr(:npm) { 49 }
  # mock_attr(:system_packages) { 830 }
  #

  def avatar
    RubyIdenticon.create_base64(self.name, :border_size => 10)
  end

  def to_param
    uuid
  end
end
