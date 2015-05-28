require 'test_helper'

class CanaryClientTest < ActiveSupport::TestCase
  def setup
    @client = CanaryClient.new
  end

  describe 'status' do
    it 'returns the server status' do
      VCR.use_cassette('status') do
        assert_equal "ok", @client.status.status
      end
    end
  end

  describe 'vulnerability' do
    it 'should return the vulnerability with the supplied uuid' do
      VCR.use_cassette('vulnerability') do
        vulnerability = @client.vulnerability('554bc63b-f322-486b-9981-4f9ed601338d')
        assert_match /^Echor Gem for Ruby/, vulnerability.description
        assert_equal 17592186872303, vulnerability.osvdb.first.id
        assert_equal 17592186045447, vulnerability.criticality.id
        assert_equal '2014-01-14T00:00:00.000Z', vulnerability.reported_at
        assert_equal 17592186872304, vulnerability.cve.first.id
        assert_match /^Echor Gem/, vulnerability.title
        assert_equal 17592186872302, vulnerability.id
        assert_equal 17592186294610, vulnerability.artifact.id
        assert_equal '554bc63b-f322-486b-9981-4f9ed601338d', vulnerability.uuid
      end
    end
  end
end
