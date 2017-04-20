require 'test_helper'

class MonitorApiTest < ActionDispatch::IntegrationTest
  let(:account) {  FactoryGirl.create(:account) }

  describe "while authenticated" do
    it "should create a new monitor" do
      assert_equal 0, Bundle.count
      post api_monitors_path(name: "foo"), {platform: Platforms::Ruby, file: gemfilelock},
        {authorization: %{Token token="#{account.token}"}}

      assert_response :success
      assert_equal 1, Bundle.count

      json = json_body
      assert json.key?("data")
      assert json["data"].key?("id")
      assert_equal "monitors", json["data"]["type"]
      assert_equal "foo", json["data"]["attributes"]["name"]
      assert_equal false, json["data"]["attributes"]["vulnerable"]

      # quick v2 smokesceen test
      post api_v2_monitors_path(name: "foo2"), {platform: Platforms::Ruby, file: gemfilelock},
        {authorization: %{Token token="#{account.token}"}}

      assert_response :success
      json = json_body
      assert_equal "monitor", json["data"]["type"]
      assert_equal false, json["data"]["attributes"]["vulnerable"]
      assert json["data"]["attributes"]["created-at"]

    end

    it "should return errors when given bad params" do
       post api_monitors_path(name: "foo"), {platform: "rubby", file: gemfilelock},
         {authorization: %{Token token="#{account.token}"}}

       assert_response :bad_request
       json = json_body
       assert_not json.key?("data")
       assert_equal "Platform is invalid", json["errors"].first["title"]

       post api_monitors_path(name: "foo"), {platform: Platforms::Ruby, file: gemfile},
         {authorization: %{Token token="#{account.token}"}}

       assert_response :bad_request
       json = json_body
       assert_not json.key?("data")
       assert_equal "File has no listed packages. Are you sure it's valid?", json["errors"].first["title"]

       assert_equal 0, Bundle.count
    end

    it "should update an existing monitor" do
      @bundle = FactoryGirl.create(:bundle_with_packages, name: "foo", account: account)
      old_pkgs = @bundle.packages.to_a

      put api_monitor_path(name: "foo"), {file: gemfilelock},
        {authorization: %{Token token="#{account.token}"}}

      assert_response :success
      @bundle.reload

      assert_not_equal old_pkgs, @bundle.packages.to_a
      json = json_body
      assert json["data"].is_a? Hash
      assert_equal @bundle.id.to_s, json["data"]["id"]
      assert_equal "monitors", json["data"]["type"]
      assert_equal "foo", json["data"]["attributes"]["name"]
      assert_equal false, json["data"]["attributes"]["vulnerable"]
    end

    it "should create a monitor when PUTTING to one that doesn't exist" do
      assert_equal 0, Bundle.count

      put api_monitor_path(name: "foo"), {file: gemfilelock, platform: Platforms::Ruby},
          {authorization: %{Token token="#{account.token}"}}
      assert_response :success
      assert_equal 1, Bundle.count

      # Calling again will update
      put api_monitor_path(name: "foo"), {file: gemfilelock, platform: Platforms::Ruby},
          {authorization: %{Token token="#{account.token}"}}
      assert_response :success
      assert_equal 1, Bundle.count
    end

    it "should delete an existing monitor" do
      @bundle = FactoryGirl.create(:bundle_with_packages, name: "foo", account: account)

      delete api_monitor_path(name: "foo"), {},
        {authorization: %{Token token="#{account.token}"}}

      assert_response :no_content
      assert_equal "", response.body
    end

    it "should show an existing monitor" do
      @bundle = FactoryGirl.create(:bundle_with_packages, name: "foo", account: account)

      get api_monitor_path(name: "foo"), {},
        {authorization: %{Token token="#{account.token}"}}

      assert_response :success

      json = json_body
      assert json["data"].is_a? Hash
      assert_equal @bundle.id.to_s, json["data"]["id"]
      assert_equal "monitors", json["data"]["type"]
      assert_equal "foo", json["data"]["attributes"]["name"]
      assert_equal false, json["data"]["attributes"]["vulnerable"]
      assert_equal false, json["data"].key?("relationships")

      # okay. what happens if it's vulnerable?
      FactoryGirl.create(:vulnerability, :pkgs => [@bundle.packages.first])

      get api_monitor_path(name: "foo"), {},
        {authorization: %{Token token="#{account.token}"}}

      assert_response :success

      json = json_body
      assert json["data"].is_a? Hash
      assert_equal @bundle.id.to_s, json["data"]["id"]
      assert_equal "monitors", json["data"]["type"]
      assert_equal "foo", json["data"]["attributes"]["name"]
      assert_equal true, json["data"]["attributes"]["vulnerable"]
      assert_equal true, json["data"].key?("relationships")
      assert_equal 2, json["included"].size
      assert_equal "packages", json["included"][0]["type"]
      assert_equal "vulnerabilities", json["included"][1]["type"]


      # should also work using the bundle id
      get api_monitor_path(name: @bundle.id), {},
        {authorization: %{Token token="#{account.token}"}}

      assert_response :success



      # quick v2 smokesceen test
      get api_v2_monitor_path(name: @bundle.id), {},
        {authorization: %{Token token="#{account.token}"}}
      assert_response :success

      json = json_body
      assert_equal "monitor", json["data"]["type"]
      assert_equal true, json["data"]["attributes"]["vulnerable"]
      assert json["data"]["attributes"]["vulnerable-versions"].all? { |h|
        h["attributes"]["name"].present? && h["attributes"]["number"].present? &&
          !h["attributes"]["vulnerabilities"][0]["upgrade-to"].nil?
      }


    end
  end

  describe "while not authenticated" do
    it "should not let you touch any endpoint if bad token" do
      # create
      post api_monitors_path(name: "foo"), {platform: Platforms::Ruby, file: gemfilelock},
        {authorization: %{Token token="LOLFAKE"}}

      assert_response :unauthorized
      assert_equal 0, Bundle.count
      assert_equal "Unauthorized", json_body["errors"].first["title"]

      @bundle = FactoryGirl.create(:bundle_with_packages, name: "foo", account: account)

      # show
      get api_monitor_path(name: "foo"), {},
        {authorization: %{Token token="LOLFAKE"}}
      assert_response :unauthorized
      assert_equal "Unauthorized", json_body["errors"].first["title"]


      # update
      put api_monitor_path(name: "foo"), {file: gemfilelock},
        {authorization: %{Token token="LOLFAKE"}}

      assert_response :unauthorized
      assert_equal "Unauthorized", json_body["errors"].first["title"]

      # delete
      delete api_monitor_path(name: "foo"), {},
        {authorization: %{Token token="LOLFAKE"}}

      assert_equal 1, Bundle.count
      assert_response :unauthorized
      assert_equal "Unauthorized", json_body["errors"].first["title"]
    end

    it "should not let you update SOMEONE ELSE's monitor" do
      @bundle = FactoryGirl.create(:bundle_with_packages, name: "foo", account: account)
      new_account = FactoryGirl.create(:account)
      old_pkgs = @bundle.packages.to_a

      # try PUTting to a bundle with the same name
      put api_monitor_path(name: "foo"), {platform: Platforms::Ruby, file: gemfilelock},
        {authorization: %{Token token="#{new_account.token}"}}

      # We created a *new* bundle for our account with the same name as @bundle
      assert_response :success

      # Try doing it with @bundle's id as well
      put api_monitor_path(name: @bundle.id), {platform: Platforms::Ruby, file: gemfilelock},
          {authorization: %{Token token="#{new_account.token}"}}

      # We created a *new* bundle for our account with the same name as @bundle
      assert_response :success

      # The packages of the old bundle did not change did not change
      @bundle.reload
      assert_equal old_pkgs, @bundle.packages.order(:id).to_a
    end

    it "should not let you delete someone else's monitor" do
      @bundle = FactoryGirl.create(:bundle_with_packages, name: "foo", account: account)
      assert_equal 1, Bundle.count

      new_account = FactoryGirl.create(:account)

      delete api_monitor_path(name: "foo"), {},
        {authorization: %{Token token="#{new_account.token}"}}

      assert_response :not_found
      assert_equal 1, Bundle.count
      assert_equal "No monitor with that name or id was found", json_body["errors"].first["title"]
    end

    it "should not let you see someone else's monitor" do
      @bundle = FactoryGirl.create(:bundle_with_packages, name: "foo", account: account)

      new_account = FactoryGirl.create(:account)

      get api_monitor_path(name: "foo"), {},
        {authorization: %{Token token="#{new_account.token}"}}

      assert_response :not_found
      assert_equal "No monitor with that name or id was found", json_body["errors"].first["title"]
    end
  end

  def json_body
    JSON.parse(response.body)
  end

  def gemfilelock
    @gemfilelock ||= Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "test/data/parsers", "420rails.gemfile.lock")))
  end

  def gemfile
    @gemfile ||= Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "Gemfile")))
  end

end
