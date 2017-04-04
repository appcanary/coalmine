require 'test_helper'

# All these tests don't work when you run then across a date boundary. c'est la vie
class AgentServerTest < ActiveSupport::TestCase
  describe "created_on scope" do
    it "should not get servers created yesterday" do
      travel_to 1.day.ago do
        FactoryGirl.create(:agent_server)
      end

      assert_equal [], AgentServer.created_on(Date.today)
    end

    it "should get servers created today" do
      server = FactoryGirl.create(:agent_server)

      assert_equal [server], AgentServer.created_on(Date.today)
    end

    it "should get servers created today and deleted today" do
      server = FactoryGirl.create(:agent_server)
      server.destroy!

      # The server doesn't actually exist
      assert_equal [], AgentServer.all

      # But we still see it's archive when we look for ones created today
      assert_equal [server], AgentServer.created_on(Date.today)
    end

    it "should not get servers created yesterday but deleted today" do
      server = travel_to 1.day.ago do
        FactoryGirl.create(:agent_server)
      end
      server.destroy!

      assert_equal [], AgentServer.created_on(Date.today)
    end
  end

  describe "deleted_on scope" do
    it "should not get servers deleted yesterday" do
      travel_to 1.day.ago do
        server = FactoryGirl.create(:agent_server)
        destroy_when_traveling(server)
      end

      assert_equal [], AgentServer.deleted_on(Date.today)
    end

    it "should get servers created yesterday and deleted today" do
      server = travel_to 1.day.ago do
        FactoryGirl.create(:agent_server)
      end
      server.destroy!

      assert_equal [server], AgentServer.deleted_on(Date.today)
    end

    it "should get servers created today and deleted today" do
      server = FactoryGirl.create(:agent_server)
      server.destroy!

      # The server doesn't actually exist
      assert_equal [], AgentServer.all

      # But we still see it's archive when we look for ones created today
      assert_equal [server], AgentServer.deleted_on(Date.today)
    end
  end

  def destroy_when_traveling(server)
    # Since we may be time traveling, but we can't mock out CURRENT_TIMESTAMP in postgres-land, we need to cheat a little and change the valid_at of our serverarchive
    server.destroy!

    archive = AgentServerArchive.where(agent_server_id: server.id).last
    archive.expired_at = Time.now
    archive.save
  end
end
