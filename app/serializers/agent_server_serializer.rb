class AgentServerSerializer < ActiveModel::Serializer
  type "servers"
  attributes :name, :uuid, :hostname, :last_heartbeat_at

  has_many :bundles, :serializer => AgentBundlesSerializer, unless: -> {object.bundles.empty? }, :key => "monitors"
end
