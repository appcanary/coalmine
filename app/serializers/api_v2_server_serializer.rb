class ApiV2ServerSerializer < ActiveModel::Serializer
  attributes :id, :name, :uuid, :hostname, :vulnerable
  attribute :last_heartbeat_at, key: "last-heartbeat-at"
  has_many :apps

  def vulnerable
    object.vulnerable_at_all?
  end

  def apps
    object.bundles.map { |b|
      wrap_serializer(b)
    }
  end

  def wrap_serializer(mon)
    { 
      "type" => "app",
      "attributes" => ApiV2MonitorSerializer.new(mon, instance_options)
    }
  end
end



