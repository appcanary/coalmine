class Server
  include Mocker

  mock_attr(:name) { Faker::Lorem.word }
  mock_attr(:active_issues) { [] }

  def avatar
    RubyIdenticon.create_base64(self.name, :border_size => 10)
  end
end
