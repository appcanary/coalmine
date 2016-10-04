# couldn't be arsed to figure out how to configure this
# such that it doesn't include every vuln and package id 
# when rendering the index view.
class AgentServerIndexSerializer < ActiveModel::Serializer
  type "servers"
  attributes :name, :uuid, :hostname, :last_heartbeat_at

  has_many :bundles, :serializer => AgentBundlesIndexSerializer, unless: -> {object.bundles.empty? }, :key => "monitors"
end

