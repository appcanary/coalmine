require 'test_helper'

class PackagesControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }
  let(:pkg) { FactoryGirl.create(:package) }
  let(:ubuntu_pkg) { FactoryGirl.create(:package, :ubuntu) }
  let(:vuln) { FactoryGirl.create(:vulnerability, pkgs: [pkg]) }

  describe "while authenticated" do
    setup { vuln; login_user(user) }

    test "should show ruby package w/vuln" do
      assert 1, pkg.vulnerabilities.count
      get :show, :platform => pkg.platform, :name => pkg.name, :version => pkg.version 
      assert_response :success
    end

    test "should shouw ubuntu package" do
      assert_raises ActiveRecord::RecordNotFound do
        get :show, 
          :platform => ubuntu_pkg.platform, 
          :name => ubuntu_pkg.name, 
          :version => ubuntu_pkg.version 
      end

      get :show, 
        :platform => ubuntu_pkg.platform, 
        :release => ubuntu_pkg.release, 
        :name => ubuntu_pkg.name, 
        :version => ubuntu_pkg.version 
      assert_response :success

    end
  end

  describe "while unauthenticated" do
    test "should not show ruby package w/vuln" do
      assert 1, pkg.vulnerabilities.count
      get :show, :platform => pkg.platform, :name => pkg.name, :version => pkg.version 
      assert_response :redirect
    end

  end

end
