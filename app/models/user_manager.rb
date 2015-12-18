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
        Rails.logger.error "Failed to connect to Canary backend: \n" + e.to_s
        @user.errors.add(:base, "Hrm. Seems like our backend is down. Please try again.")

        Raven.capture_exception(e)
        return false
      end
    end
  end

  def update!(params)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end

    @user.assign_attributes(params)

    if !@user.valid?
      return false
    end

    if email = params[:email]
      begin
        resp = @client.update_user({email: email})
      rescue Faraday::Error => e
        @user.errors.add(:email, "Something went wrong. Please try again.")
        Raven.capture_exception(e)
        return false
      end
    end

    begin
      intercom_email_sync!(user)
    rescue Exception => e
      @user.errors.add(:base, "Something went wrong. Please try again")
      Raven.capture_exception(e)
      return false
    end

    @user.save
  end

  def self.update(user, params)
    self.new(user).update!(params)
  end

  def intercom_keys
    ["newsletter_email_consent", "marketing_email_consent", "daily_email_consent"]
  end

  def intercom_email_sync!(user)
    ic_keys = user.changed_attributes.slice(*intercom_keys).keys
    if (ic_attr = user.attributes.slice(*ic_keys)).present?
      subscribe = ic_attr.select { |k, v| v }
      unsubscribe = ic_attr.reject { |k, v| v }

      subscribe.each do |tag, value|
        OurIntercom.tags.tag(name: tag, users: [{user_id: user.datomic_id}])
      end

      unsubscribe.each do |tag, val|
        OurIntercom.tags.untag(name: tag, users: [{user_id: user.datomic_id}])
      end
    end
  end
end

