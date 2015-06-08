require "#{File.dirname(__FILE__)}/../test_helper"

class CanaryClientTest < ActiveSupport::TestCase
  def setup
    user_token = 'ohicvf2knu0jt9u6p180vpnu6u7vk3151g0794po2mbfrgc0u4f'
    agent_token = 'p28tdt94c6fu8l3hscq2gq16uef6fncrud4s6smkfh7qfk1sam7'
    @client = CanaryClient.new(Rails.configuration.x.canary_url,
                               user_token: user_token, agent_token: agent_token)
  end

  describe 'status' do
    it 'returns the server status' do
      VCR.use_cassette('status') do
        assert_equal "ok", @client.status['status']
      end
    end
  end

  describe 'vulnerability' do
    it 'should return the vulnerability with the supplied uuid' do
      VCR.use_cassette('vulnerability') do
        vulnerability = @client.vulnerability('554bc63b-f322-486b-9981-4f9ed601338d')
        assert_match /^Echor Gem for Ruby/, vulnerability['description']
        assert_equal 17592186872303, vulnerability['osvdb'].first['id']
        assert_equal 17592186045447, vulnerability['criticality']['id']
        assert_equal '2014-01-14T00:00:00.000Z', vulnerability['reported-at']
        assert_equal 17592186872304, vulnerability['cve'].first['id']
        assert_match /^Echor Gem/, vulnerability['title']
        assert_equal 17592186872302, vulnerability['id']
        assert_equal 17592186294610, vulnerability['artifact']['id']
        assert_equal '554bc63b-f322-486b-9981-4f9ed601338d', vulnerability['uuid']
      end
    end
  end

  describe 'vulnerabilities' do
    it 'should return all vulnerabilities' do
      VCR.use_cassette('vulnerabilities') do
        vulns = @client.vulnerabilities['vulnerabilities']
        assert_equal 50, vulns.count
        v = vulns[7]
        assert_match /^Fat Free CRM contains/, v['description']
        assert_equal [{"id" => 17592186872318}], v['osvdb']
        assert_equal({"id"=>17592186045445}, v['criticality'])
        assert_equal '2013-12-24T00:00:00.000Z', v['reported-at']
        assert_match /cycling the Rails session secret$/, v['title']
      end
    end
  end

  describe 'add_user' do
    it 'should set the post body to the :data option' do
      user = FactoryGirl.create :user
      refute user.email.blank?
      VCR.use_cassette('create_user') do
        result_user = @client.add_user({name: 'bob', email: user.email})
        assert_equal user.email, result_user['email']
      end
    end
  end
end
