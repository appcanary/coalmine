require "#{File.dirname(__FILE__)}/../test_helper"

class CanaryClientTest < ActiveSupport::TestCase
  setup do
    user_token = 'sn3sel6h81cdsjl7r1ea34f4pjpqbirv40sugt3mm9d9rc7it85'
    @client = Canary.new(user_token)
  end


  def attr_smokescreen(obj, klass)
    assert_equal klass, obj.class

    params = obj.attr_params

    # all objects got attrs and a uuid
    assert obj.attributes.present?
    assert obj.uuid.present?

    params.each do |key|
      unless (val = obj.send(key)).nil?
        if obj.attr_enforce_collection_params.include?(key)
          assert val.is_a?(Array), key
        end
      end

      # simple schema test
      assert obj.attributes.has_key?(key), key
    end

    
    # TODO - enforce that has many are arrays
    obj.has_many_associations.each_pair do |key, klass|
      assert_nothing_raised do
        unless (assoc_obj = obj.send(key)).nil?
          if assoc_obj.is_a? Array
            assert assoc_obj.present?
            assoc_obj = assoc_obj.first
          end

          assert assoc_obj.class == klass
        end
      end
    end
  end

=begin

  describe 'status' do
    it 'returns the server status' do
      VCR.use_cassette('status') do
        assert_equal "ok", @client.status['status']
      end
    end
  end

  describe "vulns" do
    it "returns vulns properly wrapped" do
      VCR.use_cassette("vulnerabilities") do
        our_vulns = @client.vulnerabilities
        assert our_vulns.present?
        assert our_vulns.size > 1

        vuln = our_vulns.first
        attr_smokescreen(vuln, Vulnerability)

      end
    end

    it "returns an indiv vuln properly wrapped" do
      VCR.use_cassette("a_vulnerability") do
        vuln_uuid = "563ba056-f6f1-4327-b744-b00c92683403"
        vuln = @client.vulnerability(vuln_uuid)

        attr_smokescreen(vuln, Vulnerability)
      end
    end
  end

  describe "servers" do
    it "returns servers properly wrapped" do
      VCR.use_cassette("servers") do
        servers = @client.servers

        assert servers.present?
        assert servers.size >= 1

        server = servers.first

        attr_smokescreen(server, Server)
      end
    end

    it "returns an indiv server properly wrapped" do
      server_uuid = "5588b669-7b00-4259-a290-5bb579a86c90"
      VCR.use_cassette("a_server") do

        a_server = @client.server(server_uuid)

        attr_smokescreen(a_server, Server)
      end
    end


    it "returns a server's apps properly wrapped" do
      server_uuid = "5588b669-7b00-4259-a290-5bb579a86c90"

      VCR.use_cassette("a_server_apps") do
        a_server = @client.server_apps(server_uuid)

        # TODO wrap it up

        # attr_smokescreen(a_server, App)
      end
    end

  end

 
  describe 'add_user' do
    it 'should set the post body to the :data option' do
      user = FactoryGirl.build :user, :email => "alicezhang@example.com"
      refute user.email.blank?
      VCR.use_cassette('create_user') do
        result_user = @client.add_user({name: 'bob', email: user.email})
        assert_equal user.email, result_user['email']
      end
    end
  end

  describe 'update_user' do
    it 'should update the user email' do
      VCR.use_cassette('user_update') do
        updated_user = @client.update_user({email: "new@example.com"})
        assert_equal 'new@example.com', updated_user['email']
      end
    end
  end

=end
end
