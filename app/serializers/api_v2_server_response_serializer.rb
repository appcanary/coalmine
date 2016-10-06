class ApiV2ServerResponseSerializer < ActiveModel::Serializer
  attributes :data

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
    { 
      "type" => "server",
      "attributes" => ApiV2ServerSerializer.new(mon, instance_options)
    }
  end
end


