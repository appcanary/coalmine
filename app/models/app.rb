class App < CanaryBase
  attr_accessor :id, :name, :path, :uuid, :artifact_versions, :vulnerable_to

  # include Mocker
  # mock_attr(:id) { rand(1..100) }
  # mock_attr(:name) { Faker::App.name }
  # mock_attr(:platforms) { ["Ruby"] }
  # mock_attr(:last_synced_at) { rand(1..74).hours.ago }
  # mock_attr(:active_issues) { |app| [Vuln.new(:apps => [app])] }
  # mock_attr(:resolved_issues) { [] }
  # mock_attr(:ignored_issues) { [] }
  # mock_attr(:rubygems) { nil }
  # mock_attr(:npm) { nil }
  # 

  # mock_attr(:server) { |obj| 
  #     Server.new(:app => obj ) 
  # }

  # mock_attr(:avatar) { |obj|
  #   RubyIdenticon.create_base64(obj.name, :border_size => 10)
  # }

  # def self.fake_apps
  #   server = Server.fake_servers[0]
  #   [App.new(:name => "Airbnb for toothbrushes",
  #           :platforms => "Ruby",
  #           :last_synced_at => 2.seconds.from_now,
  #           :server => server,
  #           :id => 1,
  #           :rubygems => 34),
  #    
  #    App.new(:name => "Uber for dogs",
  #                  :platforms => "Node",
  #                  :last_synced_at => 2.seconds.from_now,
  #                  :server => server,
  #                  :id => 2,
  #                  :npm => 49,
  #            )]
  # end
  # 
  # def vulnerable?
  #   active_issues.present?
  # end

   def avatar
    RubyIdenticon.create_base64(self.name, :border_size => 10)
  end

  def to_param
    uuid
  end

  def vulnerable?
    self.vulnerable_to.present?
  end
end
