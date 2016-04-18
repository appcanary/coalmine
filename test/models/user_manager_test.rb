require 'test_helper'

class UserManagerTest < ActiveSupport::TestCase
  describe "talking to the API" do
    it "should register a user" do 
      VCR.use_cassette("user_creator") do
        @user = FactoryGirl.build(:user)
        assert UserManager.sign_up(@user)
        assert @user.errors.blank?
      end
    end
  end
  describe "handling User objects" do
    it "should fail on invalid users" do
      @user = FactoryGirl.build(:invalid_user)

      assert UserManager.sign_up(@user) == false
      assert @user.errors.present?
    end

    it "should set a token and an id" do
      @user = FactoryGirl.build(:user)
      Canary2.stubs(:new).with(anything).returns(mock_client)
      assert UserManager.sign_up(@user)

      @user.reload

      assert @user.errors.blank?
      assert_equal @user.token, "a token"
      assert_equal @user.datomic_id, 123
      assert_equal @user.new_record?, false
    end

    it "it should handle rando API failure" do
      @user = FactoryGirl.build(:user)
      Canary2.any_instance.stubs(:post).with("users", anything).raises(Faraday::Error.new)
      assert_equal UserManager.sign_up(@user), false
      assert @user.errors.present?
    end
  end

  # todo attr update, mostly covered in settings test

  private

  def mock_client
    unless @client
      @client = mock
      @client.expects(:post).with("users", anything).returns({'web-token' => 'a token', 'id' => 123})
    end
    @client
  end
end
