# TODO: convert to using result, error
class UserManager
  attr_accessor :user
  def self.sign_up(user)
    self.new(user).create!
  end

  def initialize(user)
    @user = user
  end

  def create!
    # todo: figure out how to best propagate errors
    # account.email is harder to show proper errors in ui
    @user.account = Account.new(:email => @user.email)

    if !@user.valid?
      return false
    else
      User.transaction do
        @user.save!
      end
    end
  end

  def update!(params)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end

    @user.assign_attributes(params)

    if @user.email_changed?
      @user.account.email = @user.email
    end

    if !@user.valid?
      return false
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

  def intercom_attr
    ["newsletter_email_consent", "marketing_email_consent", "daily_email_consent"]
  end

  def intercom_email_sync!(user)
    # slice out keys pertaining to intercom attr we care about
    # if their values were updated
    ic_keys = user.changed_attributes.slice(*intercom_attr).keys

    if ic_keys.present?

      # if ic attr were changed, fetch current value
      ic_attr = user.attributes.slice(*ic_keys)

      # once assigned in AR, they get cast into boolean, so just:
      ic_attr.each_pair do |tag, subscribed| 
        if subscribed
          OurIntercom.tags.tag(name: tag, users: [{user_id: user.analytics_id}])
        else
          OurIntercom.tags.untag(name: tag, users: [{user_id: user.analytics_id}])
        end
      end
    end
  end
end

