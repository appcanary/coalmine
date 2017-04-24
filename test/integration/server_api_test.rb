require 'test_helper'

class ServerApiTest < ActionDispatch::IntegrationTest
  let(:account) {  FactoryGirl.create(:account) }

  describe "while authenticated" do
    it "should list existing servers" do
      @bundle1 = FactoryGirl.create(:bundle_with_packages, name: "foo", account: account)
      @bundle2 = FactoryGirl.create(:bundle_with_packages, name: "foo2", account: account)
      @servers = [FactoryGirl.create(:agent_server, :account => account, :bundles => [@bundle1])]
      @servers << FactoryGirl.create(:agent_server, :account => account, :bundles => [@bundle2])

      get api_servers_path, {}, auth_token(account)
      assert_response :success

      body = json_body

      assert_equal body["data"].map { |h| h["id"] }.to_set, @servers.map(&:id).map(&:to_s).to_set
      assert body["data"].first["attributes"]["name"].present?
      assert body["data"].first["attributes"]["uuid"].present?

      monitors = body["included"].select { |h| h["type"] == "monitors" }
      assert_equal 2, monitors.count
      assert monitors.all? { |m|
        [@bundle1.id, @bundle2.id].include?(m["id"].to_i) &&
          m["attributes"]["vulnerable"] == false
      }

      # quick v2 smokescreen test
      get api_v2_servers_path, {}, auth_token(account)
      assert_response :success

      assert json_body["data"].all? { |s|
        s["type"] == "server" &&
          s["attributes"]["apps"].present? &&
          s["attributes"]["vulnerable"] == false
      }
    end

    it "should show an existing server" do
      @bundle1 = FactoryGirl.create(:bundle_with_packages, name: "foo", account: account)
      @vuln = FactoryGirl.create(:vulnerability, :pkgs => [@bundle1.packages.first])

      @bundle2 = FactoryGirl.create(:bundle_with_packages, name: "foo2", account: account)
      @servers = [FactoryGirl.create(:agent_server, :account => account, :bundles => [@bundle1])]
      @servers << FactoryGirl.create(:agent_server, :account => account, :bundles => [@bundle2])

      @server1 = @servers.first.reload

      get api_server_path(:uuid => @server1.uuid), {}, auth_token(account)
      assert_response :success

      body = json_body
      assert_equal @server1.id.to_s, body["data"]["id"]
      assert_equal [@server1.name, @server1.uuid], body["data"]["attributes"].slice("name", "uuid").values

      monitors = body["included"].select { |h| h["type"] == "monitors" }

      assert_equal 1, monitors.count
      assert_equal @bundle1.id.to_s, monitors.first["id"]
      assert_equal true, monitors.first["attributes"]["vulnerable"]


      packages = body["included"].select { |h| h["type"] == "packages" }
      vulns = body["included"].select { |h| h["type"] == "vulnerabilities" }

      assert_equal 1, packages.count
      assert_equal @bundle1.packages.first.id.to_s, packages.first["id"]

      assert_equal 1, vulns.count
      assert_equal @vuln.id.to_s, vulns.first["id"]

      # while we're at it, should also get server by id
      get api_server_path(:uuid => @server1.id), {}, auth_token(account)
      assert_response :success

      # unless it doesnt exit
      get api_server_path(:uuid => "FAKE"), {}, auth_token(account)
      assert_response :not_found
      assert_equal "No server with that id was found", json_body["errors"].first["title"]

      # quick v2 smokescreen test
      get api_v2_server_path(:uuid => @server1.uuid), {}, auth_token(account)
      assert_response :success

      json = json_body
      assert_equal "server", json["data"]["type"] = "server"
      assert json["data"]["attributes"]["apps"].present?
    end

    it "should delete a server" do
      @bundle1 = FactoryGirl.create(:bundle_with_packages, name: "foo", account: account)
      @server1 = FactoryGirl.create(:agent_server, :account => account, :bundles => [@bundle1]).reload

      assert_equal 1, AgentServer.count
      assert_equal 1, Bundle.count

      delete api_server_path(:uuid => @server1.uuid), {}, auth_token(account)
      assert_response :no_content

      assert_equal 0, AgentServer.count
      assert_equal 0, Bundle.count
    end
  end

  describe "while unauthenticated" do
    it "should not list squat" do
      @server1 = FactoryGirl.create(:agent_server, :account => account).reload
      get api_servers_path, {}, auth_token(Struct.new(:token).new("FAKE"))

      assert_response :unauthorized
      assert_equal "Unauthorized", json_body["errors"].first["title"]
    end

    it "should not list other people's servers" do
      @server1 = FactoryGirl.create(:agent_server, :account => account).reload
      account2 = FactoryGirl.create(:account)

      get api_server_path(:uuid => @server1.uuid), {}, auth_token(account2)

      assert_response :not_found
      assert_equal "No server with that id was found", json_body["errors"].first["title"]


      get api_servers_path(:uuid => @server1.uuid), {}, auth_token(Struct.new(:token).new("FAKE"))
      assert_response :unauthorized
      assert_equal "Unauthorized", json_body["errors"].first["title"]
    end

    it "should not let you delete other people's servers neither" do
      @server1 = FactoryGirl.create(:agent_server, :account => account).reload
      account2 = FactoryGirl.create(:account)

      assert_equal 1, AgentServer.count

      delete api_server_path(:uuid => @server1.uuid), {}, auth_token(account2)
      assert_response :not_found

      assert_equal 1, AgentServer.count
    end
  end

  def auth_token(account)
    {authorization: %{Token token="#{account.token}"}}
  end

  def json_body
    JSON.parse(response.body)
  end
end
