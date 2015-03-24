class Server
  include Mocker

  mock_attr(:id) { 1 }
  mock_attr(:name) { Faker::Lorem.word }
  mock_attr(:active_issues) { [] }
  mock_attr(:last_synced_at) { Time.now }
  mock_attr(:rubygems) { 34 }
  mock_attr(:npm) { 49 }
  mock_attr(:system_packages) { 830 }
  

  mock_attr(:avatar) { |obj|
    RubyIdenticon.create_base64(obj.name, :border_size => 10)
  }

  def self.fake_servers
    [Server.new(:name => "free-micro-aws",
               :id => 1)]
  end
end
