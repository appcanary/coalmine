class CanaryBase
  include TrackAttributes
  extend ActiveModel::Naming

  attr_accessor :canary
 
  def initialize(params={})
    params.each do |attr, value|
      setter = attr.tr("-", "_")
      self.public_send("#{setter}=", value)
    end if params
  end

  def attributes
    Hash[attr_accessors.map { |k| [k, send(k)] }]
  end

  def self.parse(canary, params)
    self.new(params).tap do |obj|
      obj.canary = canary
    end
  end
end

