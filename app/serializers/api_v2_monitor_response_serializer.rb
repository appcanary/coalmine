class ApiV2MonitorResponseSerializer < ActiveModel::Serializer
  attributes :data, :meta

  def data
    # if we're being called in a show action
    # this is not a collection
    if object.respond_to?(:map)
      object.map do |mon|
        wrap_serializer(mon)
      end
    else
      wrap_serializer(object)
    end
  end

  def wrap_serializer(mon)
    { "type" => "monitor",
      "attributes" => ApiV2MonitorSerializer.new(mon, instance_options)
    }
  end

  
  def meta
    {deprecated: "This endpoint is no longer supported."}
  end
end

