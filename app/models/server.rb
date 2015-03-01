class Server
  include Mocker

  mock_attr(:name) { Faker::Lorem.word }
  mock_attr(:active_issues) { [] }
end
