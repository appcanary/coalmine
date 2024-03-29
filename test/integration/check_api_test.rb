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

      # v2 smokescreen test
      post api_v2_check_path, {platform: Platforms::Ruby, file: gemfilelock},
        {authorization: %{Token token="#{account.token}"}}
      assert_response :success

      json = json_body
      assert_equal false, json["vulnerable"]
    end


    describe "for ruby" do
      it "should tell you you're vulnerable" do
        pkg = FactoryGirl.create(:package, :ruby, :name => "actionmailer", :version => "4.2.0")
        vuln = FactoryGirl.create(:vulnerability, :pkgs => [pkg])

        assert_equal 0, account.log_api_calls.where(:action => "check/create").count
        post api_check_path, {platform: Platforms::Ruby, file: gemfilelock},
          {authorization: %{Token token="#{account.token}"}}

        assert_response :success

        assert_equal 1, account.log_api_calls.where(:action => "check/create").count
        # Make sure we log the right platform release
        assert_equal "ruby", account.log_api_calls.last.platform
        assert_nil account.log_api_calls.last.release

        json = json_body
        assert json.key?("data")
        assert_equal 1, json["data"].size

        json_pkg = json["data"].first
        assert_equal "actionmailer", json_pkg["attributes"]["name"]
        assert json_pkg["relationships"].key?("vulnerabilities")

        assert_equal "vulnerabilities", json["included"].first["type"]
        assert json["included"].first["attributes"].key?("reference-ids")

        assert_equal true, json["meta"]["vulnerable"]
      end
    end

    describe "for php" do
      it "should tell you you're vulnerable" do
        pkg = FactoryGirl.create(:package, :php, name: "composer/semver", version: "1.4.2")
        vuln = FactoryGirl.create(:vulnerability, pkgs: [pkg])

        assert_equal 0, account.log_api_calls.where(action: "check/create").count
        post api_check_path, {platform: Platforms::PHP, file: composerlock},
             {authorization: %{Token token="#{account.token}"}}

        assert_response :success

        assert_equal 1, account.log_api_calls.where(:action => "check/create").count
        # Make sure we log the right platform release
        assert_equal "php", account.log_api_calls.last.platform
        assert_nil account.log_api_calls.last.release

        json = json_body
        assert json.key?("data")
        assert_equal 1, json["data"].size

        json_pkg = json["data"].first
        assert_equal "composer/semver", json_pkg["attributes"]["name"]
        assert json_pkg["relationships"].key?("vulnerabilities")

        assert_equal "vulnerabilities", json["included"].first["type"]
        assert json["included"].first["attributes"].key?("reference-ids")

        assert_equal true, json["meta"]["vulnerable"]
      end
    end

    describe "for centos" do
      it "should tell you you're vulnerable" do
        pkg = FactoryGirl.create(:package, :centos, :release => "7", :name => "openssh", :version => "openssh-6.6.2p1-22.el7.x86_64")
        vuln = FactoryGirl.create(:vulnerability, :pkgs => [pkg])

        assert_equal 0, account.log_api_calls.where(:action => "check/create").count

        authed_post(account, {platform: Platforms::CentOS, release: "7", file: centosqa})

        assert_response :success

        assert_equal 1, account.log_api_calls.where(:action => "check/create").count
        # Make sure we log the right platform release
        assert_equal "centos", account.log_api_calls.last.platform
        assert_equal "7", account.log_api_calls.last.release

        json = json_body
        assert json.key?("data")
        assert_equal 1, json["data"].size

        json_pkg = json["data"].first
        assert_equal "openssh", json_pkg["attributes"]["name"]
        assert_check_response_shape(json)
      end
    end

    describe "for amazon" do
      it "should tell you you're vulnerable" do
        vuln = FactoryGirl.create(:vulnerability, :amzn)
        FactoryGirl.create(:vulnerable_dependency, 
                           :vulnerability => vuln,
                           :platform => Platforms::Amazon,
                           :release => nil, # amazon vds have no releases
                           :package_name => "bind-utils",
                           :patched_versions => ["bind-utils-9.8.2-0.37.rc1.47.amzn1.x86_64"])


        assert_equal 0, account.log_api_calls.where(:action => "check/create").count

        authed_post(account, {platform: Platforms::Amazon, release: "2016.03", file: amazonqa})

        assert_response :success

        assert_equal 1, account.log_api_calls.where(:action => "check/create").count
        # Make sure we log the right platform release
        assert_equal "amzn", account.log_api_calls.last.platform
        assert_equal "2016.03", account.log_api_calls.last.release

        json = json_body
        assert json.key?("data")
        assert_equal 1, json["data"].size

        json_pkg = json["data"].first
        assert_equal "bind-utils", json_pkg["attributes"]["name"]
        assert_check_response_shape(json)
      end
    end


    describe "for debian" do
      it "should tell you you're vulnerable" do
        vuln = FactoryGirl.create(:vulnerability, :debian)
        vd = FactoryGirl.create(:vulnerable_dependency, 
                                :vulnerability => vuln,
                                :platform => Platforms::Debian,
                                :release => "jessie",
                                :package_name => "openssh",
                                :patched_versions => ["1:9.2p1-1"])

        assert_equal 0, account.log_api_calls.where(:action => "check/create").count

        authed_post(account, {platform: Platforms::Debian, release: "jessie", file: debianstatus})

        assert_response :success

        assert_equal 1, account.log_api_calls.where(:action => "check/create").count
        # Make sure we log the right platform release
        assert_equal "debian", account.log_api_calls.last.platform
        assert_equal "jessie", account.log_api_calls.last.release

        json = json_body
        assert json.key?("data")
        assert_equal 3, json["data"].size

        assert json["data"].all? { |hsh|
          ["openssh-server", 
           "openssh-sftp-server", 
           "openssh-client"].include?  hsh["attributes"]["name"]
        }
        assert_check_response_shape(json)
      end
    end


    describe "for ubuntu" do
      it "should tell you you're vulnerable" do
        vuln = FactoryGirl.create(:vulnerability, :ubuntu)
        vd = FactoryGirl.create(:vulnerable_dependency, 
                                :vulnerability => vuln,
                                :platform => Platforms::Ubuntu,
                                :release => "trusty",
                                :package_name => "openssh",
                                :patched_versions => ["1:9.2p1-1"])

        assert_equal 0, account.log_api_calls.where(:action => "check/create").count

        authed_post(account, {platform: Platforms::Ubuntu, release: "trusty", file: ubuntustatus})

        assert_response :success

        assert_equal 1, account.log_api_calls.where(:action => "check/create").count

        # Make sure we log the right platform release
        assert_equal "ubuntu", account.log_api_calls.last.platform
        assert_equal "trusty", account.log_api_calls.last.release

        json = json_body
        assert json.key?("data")
        assert_equal 3, json["data"].size

        assert json["data"].all? { |hsh|
          ["openssh-server", 
           "openssh-sftp-server", 
           "openssh-client"].include?  hsh["attributes"]["name"]
        }
        assert_check_response_shape(json)
      end
    end


    describe "for alpine linux" do
      it "should tell you you're vulnerable" do
        vuln = FactoryGirl.create(:vulnerability, :alpine)
        vd = FactoryGirl.create(:vulnerable_dependency,
                                :vulnerability => vuln,
                                :platform => Platforms::Alpine,
                                :release => "3.5",
                                :package_name => "syslinux",
                                :patched_versions => ["6.06-r0"])

        assert_equal 0, account.log_api_calls.where(:action => "check/create").count

        # Note that the point version (.2) of the release will get stripped
        authed_post(account, {platform: Platforms::Alpine, release: "3.5.2", file: apkinstalled})

        assert_response :success

        assert_equal 1, account.log_api_calls.where(:action => "check/create").count

        # Make sure we log the right platform release
        assert_equal "alpine", account.log_api_calls.last.platform
        # Note we're not stripping the release in the logs, only below
        assert_equal "3.5.2", account.log_api_calls.last.release

        json = json_body
        assert json.key?("data")
        assert_equal 1, json["data"].size

        assert_equal "syslinux", json["data"].first["attributes"]["name"]

        # We stripped the point release value when processing the bundle
        assert_equal "3.5", json["data"].first["attributes"]["release"]
        assert_check_response_shape(json)
      end
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

  def authed_post(account, h)
    post api_check_path, h,
      {authorization: %{Token token="#{account.token}"}}

  end

  def assert_check_response_shape(json)
    assert json["data"].first["relationships"].key?("vulnerabilities")

    assert_equal "vulnerabilities", json["included"].first["type"]
    assert json["included"].first["attributes"].key?("reference-ids")

    assert_equal true, json["meta"]["vulnerable"]
  end

  def gemfilelock
    @gemfilelock ||= uploaded_file("420rails.gemfile.lock")
  end

  def composerlock
    @composerlock ||= uploaded_file("drupal.composer.lock")
  end

  def debianstatus
    @debianstatus ||= uploaded_file("debian-jessie-dpkg-status.txt")
  end

  def ubuntustatus
    @ubuntustatus ||= uploaded_file("ubuntu-trusty-dpkg-status.txt")
  end

  def centosqa
    @centosqa ||= uploaded_file("centos-7-rpmqa.txt")
  end

  def amazonqa
    @amazonqa ||= uploaded_file("amazon-rpmqa.txt")
  end

  def apkinstalled
    @apkinstalled ||= uploaded_file("alpine-installed-3.5.2.txt")
  end

  def gemfile
    @gemfile ||= Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "Gemfile")))
  end

  def uploaded_file(filename)
    Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, "test/data/parsers", filename)))
  end
end
