require 'test_helper'

class UserCreatorTest < ActiveSupport::TestCase
  describe "UserCreator#sign_up" do
    it "should fail on invalid users" do
      @user = FactoryGirl.build(:invalid_user)

      assert UserCreator.sign_up(@user) == false
      assert @user.errors.present?
    end

    it "should set a token" do
      @user = FactoryGirl.build(:user)
      Canary.stub :create_user, "a token" do
        assert UserCreator.sign_up(@user)
        assert @user.errors.blank?
        assert_equal @user.token, "a token"
        assert_equal @user.new_record?, false
      end
    end

    it "it should handle rando API failure" do
      @user = FactoryGirl.build(:user)
      Canary.stub :create_user, -> (bar) { raise "oh no" } do
         assert_equal UserCreator.sign_up(@user), false
         assert @user.errors.present?
      end
    end
  end
end
