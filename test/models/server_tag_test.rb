# == Schema Information
#
# Table name: server_tags
#
#  id              :integer          not null, primary key
#  agent_server_id :integer
#  tag_id          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_server_tags_on_agent_server_id             (agent_server_id)
#  index_server_tags_on_agent_server_id_and_tag_id  (agent_server_id,tag_id) UNIQUE
#  index_server_tags_on_tag_id                      (tag_id)
#

require 'test_helper'

class ServerTagTest < ActiveSupport::TestCase
  let(:server) { FactoryGirl.create(:agent_server) }
  let(:tag) { FactoryGirl.create(:tag) }

  it "doesn't allow duplicate taggings" do
    st = ServerTag.create(tag: tag, agent_server: server)
    assert st

    assert_raises(ActiveRecord::RecordNotUnique) do
      ServerTag.create(tag: tag, agent_server: server)
    end
  end
end
