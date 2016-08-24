require 'test_helper'

class MonitorApiTest < ActionDispatch::IntegrationTest
  before do
    @account = FactoryGirl.create(:account)
  end

  describe "while authenticated" do
    it "should create a new monitor" do
      assert_equal 0, Bundle.count
      post api_monitors_path(name: "foo"), {platform: Platforms::Ruby, file: gemfile},
      {authorization: %{Token token="#{@account.token}"}}

      assert_response :success
      assert_equal 1, Bundle.count
      
      json = json_body
      assert json.key?("data")
      assert json["data"].is_a? Hash
      assert json["data"].key?("id")
      assert_equal "monitors", json["data"]["type"]
      assert_equal "foo", json["data"]["attributes"]["name"]
      assert_equal false, json["data"]["attributes"]["vulnerable"]
    end

    it "should update an existing monitor" do
      # @bundle = FactoryGirl.create(:bundle_with_packages, name: "foo", account: @account)
      # old_pkgs = @bundle.packages.to_a

      # put api_monitor_path(name: "foo"), {file: gemfile},
      # {authorization: %{Token token="#{@account.token}"}}

      # assert_response :success
      # @bundle.reload

    end
  end

  def json_body
    JSON.parse(response.body)
  end

  def gemfile
    @gemfile ||= Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "test/fixtures", "420rails.gemfile.lock")))
  end
end
