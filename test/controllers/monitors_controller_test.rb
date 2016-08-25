require 'test_helper'

class MonitorsControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }
  let(:monitor) { FactoryGirl.build(:moniter) }

  describe "while authenticated" do
    setup do
      login_user(user)
    end

    it "should show the show page" do
      FactoryGirl.create(:bundle, :account_id => user.account_id, :id => "1234")
      get :show, :id => "1234"
      assert_response :success
    end

    it "should redirect to dashboard on destroy" do
      FactoryGirl.create(:bundle, :account_id => user.account_id, :id => "1234")
      delete :destroy, :id => "1234"
      assert_response :redirect
      assert_equal 0, Bundle.count
    end

    it "should show the new page" do
      get :new
      assert_response :success
    end

    it "should allow new monitors to be created" do
      post :create, {:monitor => {:file => Rack::Test::UploadedFile.new(File.join(Rails.root, "test/data", "Gemfile.lock"), nil, false),
                                  :platform_release_str => "ruby",
                                  :name => "foo"}}
      assert_redirected_to dashboard_path
    end

    it "should present an error when given bad input" do
      post :create, {:monitor => {:file => Rack::Test::UploadedFile.new(File.join(Rails.root, "test/data", "Gemfile.lock"), nil, false),
                                  :platform_release_str => "rubyLOL"}}

      assert_response :success
      assert_equal false, assigns(:form).valid?
    end

    it "should present an error when given a bad file" do
      post :create, {:monitor => {:file => Rack::Test::UploadedFile.new(File.join(Rails.root, "test/data", "Gemfile"), nil, false),
                                  :platform_release_str => "ruby"}}

      assert_response :success
      assert_equal false, assigns(:form).valid?
    end
  end

  describe "while unauthenticated" do
    it "show should be redirected" do
      get :show, :id => "1234"
      assert_response :redirect
    end

    it "delete should be redirected" do
      delete :destroy, :id => "1234"
      assert_response :redirect
    end

  end

end
