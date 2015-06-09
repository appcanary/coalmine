class CanaryBase
  include TrackAttributes
  def initialize(params={})
    params.each do |attr, value|
      setter = attr.tr("-", "_")
      self.public_send("#{setter}=", value)
    end if params
  end

  def attributes
    Hash[attr_accessors.map { |k| [k, send(k)] }]
  end
end

