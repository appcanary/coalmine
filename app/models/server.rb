class Server
  include Mocker

  mock_attr(:name) { Faker::Lorem.word }
  mock_attr(:active_issues) { [] }

  mock_attr(:avatar) { |obj|
    RubyIdenticon.create_base64(obj.name, :border_size => 10)
  }
end
