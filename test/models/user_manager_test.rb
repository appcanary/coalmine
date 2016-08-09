require 'test_helper'

class UserManagerTest < ActiveSupport::TestCase
  describe "talking to the API" do
    it "should register a user" do 
      @user = FactoryGirl.build(:user)
      assert UserManager.sign_up(@user)
      assert @user.errors.blank?
    end
  end
  describe "handling User objects" do
    it "should fail on invalid users" do
      @user = FactoryGirl.build(:invalid_user)

      assert UserManager.sign_up(@user) == false
      assert @user.errors.present?
    end

    it "should create an account w/same email" do
      assert_equal 0, Account.count
      @user = FactoryGirl.build(:user)
      assert UserManager.sign_up(@user)
      assert_equal 1, Account.count

      @user.reload

      assert @user.errors.blank?
      assert_equal Account.first.email, @user.account.email
      assert_equal @user.new_record?, false
    end

    it "shouldn't let you create a new user whose email is used by an existing account" do
      email = "fake@example.com"
      FactoryGirl.create(:account, :email => email)

      @user = FactoryGirl.build(:user, :email => email)
      assert_equal false, UserManager.sign_up(@user)

      assert @user.errors.present?
    end

    it "should for now auto update the account email when you change user email" do
      email_str = "test@example.com"

      acc = FactoryGirl.create(:account)
      user = FactoryGirl.create(:user, :account => acc)
      
      ret = UserManager.update(user, {:email => email_str})

      acc.reload
      user.reload
      
      assert_equal email_str, user.email
      assert_equal email_str, acc.email
    end
  end

  # todo attr update, mostly covered in settings test

end
