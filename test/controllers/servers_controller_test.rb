require 'test_helper'

class ServersControllerTest < ActionController::TestCase
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin_user) }

  describe "while authenticated" do

    setup do
      login_user(user)
    end

    it "should show the show page" do
      bundle = FactoryGirl.create(:bundle_with_packages, :account => user.account)
      FactoryGirl.create(:agent_server, :id => 1234, :account => user.account, :bundles => [bundle])
      get :show, :id => "1234"
      assert_response :success
    end

    it "should export as a csv" do
      require 'csv'

      bundle = FactoryGirl.create(:bundle_with_packages, :account => user.account)
      vulnp = bundle.packages.first
      vuln = FactoryGirl.create(:vulnerability, pkgs: [vulnp])

      vuln_server = FactoryGirl.create(:agent_server, :centos, :account => user.account, :bundles => [bundle], :id => 1234)

      get :show, :id => "1234", :format => "csv"
      assert_equal "text/csv", response.content_type
      assert_equal "binary", response.headers["Content-Transfer-Encoding"]

      file = CSV.parse(response.body)
      assert_equal ["Name", "Last Heartbeat", "Distro / Release", "Vulnerable?"], file[0]

      assert_equal vuln_server.name, file[1][0]

      # we list one line per vulnerability
      assert_equal vuln.reference_ids.first, file[4][2]
      assert_equal vulnp.name, file[4][1]
    end

    it "should show the new page" do
      User.any_instance.stubs(:agent_token).returns("1234")
      get :new
      assert_response :success
      assert assigns(:agent_token)
    end

    it "should get deleted" do
      this_server = FactoryGirl.create(:agent_server, :account => user.account)

      # there was an error reported when a user tried to delete a server
      # that had an accepted file, due to a foreign key violation, hence this test. 
      # there ought to be a better way to test these relationships automatically
      this_server.received_files.create(:account => user.account)
      this_server.accepted_files.create(:account => user.account)

      assert_equal 1, AgentServer.count
      delete :destroy, :id => this_server.id
      assert_equal 0, AgentServer.count
    end

    it "shouldn't show another user's server" do
      another_server = FactoryGirl.create(:agent_server, :account => user2.account)
      assert_raises(ActiveRecord::RecordNotFound) do
        get :show, :id => another_server.id
      end
    end
  end

  describe "while admin" do
    setup do
      login_user(admin)
    end

    it "should show another user's server" do
      another_server = FactoryGirl.create(:agent_server, :account => user2.account)
      get :show, :id => another_server.id
      assert_response :success
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
