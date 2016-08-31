require 'test_helper'

class CheckApiTest < ActionDispatch::IntegrationTest
  let(:account) {  FactoryGirl.create(:account) }
  describe "while authenticated" do
    it "should tell you if you're not vulnerable" do
      assert_equal 0, account.log_api_calls.where(:action => "check/create").count
      post api_check_path, {platform: Platforms::Ruby, file: gemfilelock},
        {authorization: %{Token token="#{account.token}"}}

      assert_response :success
      assert_equal 1, account.log_api_calls.where(:action => "check/create").count
      
      json = json_body
      assert json.key?("data")
      assert json["data"].empty?
      assert_equal false, json["meta"]["vulnerable"]
    end

    it "should tell you you're vulnerable" do
      pkg = FactoryGirl.create(:package, :ruby, :name => "actionmailer", :version => "4.2.0")
      vuln = FactoryGirl.create(:vulnerability, :pkgs => [pkg])

      assert_equal 0, account.log_api_calls.where(:action => "check/create").count
      post api_check_path, {platform: Platforms::Ruby, file: gemfilelock},
        {authorization: %{Token token="#{account.token}"}}

      assert_response :success
      
      assert_equal 1, account.log_api_calls.where(:action => "check/create").count

      json = json_body
      assert json.key?("data")
      assert_equal 1, json["data"].size

      json_pkg = json["data"].first
      assert_equal "actionmailer", json_pkg["attributes"]["name"]
      assert json_pkg["relationships"].key?("vulnerabilities")

      assert_equal "vulnerabilities", json["included"].first["type"]
      assert json["included"].first["attributes"].key?("cve-ids")

      assert_equal true, json["meta"]["vulnerable"]
    end

    it "should provide you with errors when given bad params" do
      post api_check_path, {platform: "rubby", file: gemfilelock},
        {authorization: %{Token token="#{account.token}"}}


      assert_response :bad_request
      assert_equal 0, account.log_api_calls.where(:action => "check/create").count

      json = json_body
      assert_not json.key?("data")
      assert_equal "Platform is invalid", json["errors"].first["title"]


      post api_check_path, {platform: Platforms::Ruby, file: gemfile},
        {authorization: %{Token token="#{account.token}"}}
      assert_equal 0, account.log_api_calls.where(:action => "check/create").count

      assert_response :bad_request
      json = json_body
      assert_not json.key?("data")
      assert_equal "File has no listed packages. Are you sure it's valid?", json["errors"].first["title"]
    end
  end

  describe "while not authenticated" do
    it "shouldn't let you do anything" do
      post api_check_path, {platform: Platforms::Ruby, file: gemfilelock},
        {authorization: %{Token token="LOLFAKE"}}

      assert_response :unauthorized
      assert_equal "Unauthorized", json_body["errors"].first["title"]
    end
  end

  def json_body
    JSON.parse(response.body)
  end

  def gemfilelock
    @gemfilelock ||= Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "test/fixtures", "420rails.gemfile.lock")))
  end

  def gemfile
    @gemfile ||= Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "Gemfile")))
  end


end