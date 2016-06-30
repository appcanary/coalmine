require 'test_helper'

class MonitorsControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }
  let(:monitor) { FactoryGirl.build(:moniter) }

  before(:suite) do
    Moniter.stubs(:find).with(anything, anything).returns(monitor)
  end


  describe "while authenticated" do
    setup do
      login_user(user)
    end

    it "should show the show page" do
      get :show, :id => "1234"
      assert_response :success
    end

    it "should redirect to dashboard on destroy" do
      Moniter.expects(:destroy).with(user, "1234").returns(true)

      delete :destroy, :id => "1234"
      assert_response :redirect
    end

    it "should show the new page" do
      get :new
      assert_response :success
    end

    it "should allow new monitors to be created" do
      VCR.use_cassette("monitor_create") do
        post :create, {:moniter => {:file => Rack::Test::UploadedFile.new(File.join(Rails.root, "test/data", "Gemfile.lock"), nil, false),
                                    :platform_release => "ruby"}}
        assert_redirected_to dashboard_path
      end
    end

    it "should present an error when given bad input" do
      post :create, {:moniter => {:file => Rack::Test::UploadedFile.new(File.join(Rails.root, "test/data", "Gemfile.lock"), nil, false),
                                  :platform_release => "rubyLOL"}}

      assert_response :success
      assert_not_nil assigns(:monitor).errors
    end

    it "should present an error when given a bad file" do
      VCR.use_cassette("monitor_create_error") do 
        post :create, {:moniter => {:file => Rack::Test::UploadedFile.new(File.join(Rails.root, "test/data", "Gemfile"), nil, false),
                                    :platform_release => "ruby"}}

        assert_response :success
        assert_not_nil assigns(:monitor).errors
      end
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
