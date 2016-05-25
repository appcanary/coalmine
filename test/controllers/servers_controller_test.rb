require 'test_helper'

class ServersControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }
  let(:server) { FactoryGirl.build(:server) }

  before(:suite) do
    Server.stubs(:find).with(anything, anything).returns(server)
  end

  describe "while authenticated" do

    setup do
      login_user(user)
    end

    it "should show the show page" do
      get :show, :id => "1234"
      assert_response :success
    end

    it "should export as a cvs" do
      require 'csv'
      
      vuln_app = FactoryGirl.build(:vulnerable_app)
      vuln_server = FactoryGirl.build(:server, :attributes => {"apps" =>  [vuln_app]})
      Server.stubs(:find).with(anything, anything).returns(vuln_server)
      App.stubs(:find).with(anything, anything, anything).returns(vuln_app)

      get :show, :id => "1234", :format => "csv"
      assert_equal "text/csv", response.content_type
      assert_equal "binary", response.headers["Content-Transfer-Encoding"]

      file = CSV.parse(response.body)
      assert_equal ["Name", "Last Heartbeat", "Distro / Release", "Vulnerable?"], file[0]

      assert_equal vuln_server.name, file[1][0]

      # we list one line per vulnerability
      assert_equal vuln_app.vulnerable_artifact_versions.map(&:vulnerability).flatten.count, file[4..-1].count

    end

    it "should show the new page" do
      User.any_instance.stubs(:agent_token).returns("1234")
      Backend.stubs(:artifacts_count).returns("1235")
      Backend.stubs(:vulnerabilities_count).returns("1236")
      get :new
      assert_response :success
      assert assigns(:agent_token)
    end
  end

  describe "while unauthenticated" do
    it "show should be redirected" do
      get :show, :id => "1234"
      assert_response :redirect
    end

    it "new should be redirected" do
      get :new
      assert_response :redirect
    end

    it "should get the install script" do
      get :install
      assert_equal "text/x-shellscript", response.content_type
      assert_equal "inline; filename=\"appcanary.debian.sh\"", response.headers["Content-Disposition"]
      assert_equal "binary", response.headers["Content-Transfer-Encoding"]
      assert_equal File.read(File.join(Rails.root, "lib/assets/script.deb.sh")), response.body
    end

    it "should get the deb script" do
      get :deb
      assert_equal "text/x-shellscript", response.content_type
      assert_equal "inline; filename=\"appcanary.debian.sh\"", response.headers["Content-Disposition"]
      assert_equal "binary", response.headers["Content-Transfer-Encoding"]
      assert_equal File.read(File.join(Rails.root, "lib/assets/script.deb.sh")), response.body
    end

    it "should get the rpm script" do
      get :rpm
      assert_equal "text/x-shellscript", response.content_type
      assert_equal "inline; filename=\"appcanary.debian.sh\"", response.headers["Content-Disposition"]
      assert_equal "binary", response.headers["Content-Transfer-Encoding"]
      assert_equal File.read(File.join(Rails.root, "lib/assets/script.rpm.sh")), response.body
    end

  end
end
