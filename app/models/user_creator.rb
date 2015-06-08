class UserCreator
  attr_accessor :user

  def self.sign_up(user)
    self.new(user).create!
  end

  def initialize(user)
    @user = user
  end

  def create!
    if !@user.valid?
      return false
    else
      # password checks out, lets fetch our token
      begin
        client = CanaryClient.new(Rails.configuration.x.canary_url)
        backend_user = client.add_user({email: user.email, name: ''})
        @user.token = backend_user['web-token']
        return @user.save
      rescue Faraday::Error => e
        Rails.logger.error "Failed to connect to Canary backend: \n" + e.to_s
        # differentiate between exceptions later
        @user.errors.add(:to_be_determined, "foobar")
        # handle error
        return false
      end
    end
  end
end
