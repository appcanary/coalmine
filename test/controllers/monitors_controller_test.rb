require 'test_helper'

class MonitorsControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }
  let(:monitor) { FactoryGirl.build(:moniter) }

  describe "while authenticated" do
    setup do
      login_user(user)
      FactoryGirl.create(:bundle_with_packages, :account_id => user.account_id, :id => "1234")
    end

    it "should show the show page" do
      get :show, :id => "1234"
      assert_response :success
    end

    it "should redirect to dashboard on destroy" do
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

    it "should delete the bundle" do
      bundle = FactoryGirl.create(:bundle, :account_id => user.account_id)
      assert_equal 2, Bundle.count

      delete :destroy, :id => bundle.id
      assert_response :redirect

      assert_equal 1, Bundle.count
    end

    it "should add packages to resolution log" do
      a_vuln_pkg = Bundle.first.packages.first

      vuln = FactoryGirl.create(:vulnerability, :pkgs => [a_vuln_pkg])

      assert_equal 0, LogResolution.count
      request.env["HTTP_REFERER"] = "/"
      post :resolve_vuln, {:package_id => a_vuln_pkg.id, :log_resolution => {:package_id => a_vuln_pkg.id}}

      assert_response :redirect
      assert_equal 1, LogResolution.count
    end

    it "should remove packages from resolution log" do
      a_vuln_pkg = Bundle.first.packages.first

      vuln = FactoryGirl.create(:vulnerability, :pkgs => [a_vuln_pkg])
      LogResolution.resolve_package(user, a_vuln_pkg)

      assert_equal 1, LogResolution.count
      request.env["HTTP_REFERER"] = "/"
      post :unresolve_vuln, {:package_id => a_vuln_pkg.id, :log_resolution => {:package_id => a_vuln_pkg.id}}

      assert_response :redirect
      assert_equal 0, LogResolution.count
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
