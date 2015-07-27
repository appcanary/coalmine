class UserManager
  attr_accessor :user

  def self.sign_up(user)
    self.new(user).create!
  end

  def initialize(user)
    @client = Canary.new(user.token)
    @user = user
  end

  def create!
    if !@user.valid?
      return false
    else
      # password checks out, lets fetch our token
      begin
        backend_user = @client.add_user({email: user.email, name: ''})
        @user.token = backend_user['web-token']
        return @user.save
      rescue Faraday::Error => e
        # TODO: must register an error via sentry, etc
        Rails.logger.error "Failed to connect to Canary backend: \n" + e.to_s
        # differentiate between exceptions later
        @user.errors.add(:to_be_determined, "foobar")
        # handle error
        return false
      end
    end
  end

  def update!(params)
    true
  end

  def self.update(user, params)
    self.new(user).update!(params)
  end
end

