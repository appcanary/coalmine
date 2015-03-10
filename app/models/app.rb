class App
  include Mocker
  mock_attr(:name) { Faker::App.name }
  mock_attr(:platforms) { ["Ruby"] }
  mock_attr(:last_synced_at) { rand(1..74).hours.ago }
  mock_attr(:active_issues) { [] }
  mock_attr(:resolved_issues) { [] }
  mock_attr(:ignored_issues) { [] }

  mock_attr(:servers) { |obj| 
    rand(1..10).times.map do 
      Server.new(:app => obj ) 
    end 
  }

  def avatar
    RubyIdenticon.create_base64(self.name, :border_size => 10)
  end


end
