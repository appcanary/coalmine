class Canary
  include HTTParty
  base_uri Rails.configuration.canary.uri

  def self.create_user(email)
    "STUBBED FOR NOW"
  end
end
