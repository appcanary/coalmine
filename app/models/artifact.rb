class Artifact
  include Mocker
  mock_attr(:name) { Faker::Lorem.word }
  mock_attr(:vulnerabilities) { [Vulnerability.new] }
end
