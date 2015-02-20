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
        @user.token = Canary.create_user(user.email)
        return @user.save
      rescue Exception => e
        # differentiate between exceptions later
        @user.errors.add(:to_be_determined, "foobar")
        # handle error
        return false
      end
    end
  end
end
