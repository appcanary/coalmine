class CanaryBase
  include TrackAttributes
  extend ActiveModel::Naming

  attr_accessor :canary

  def self.has_many(klass, key = nil)
    @has_many ||= {}

    if key.nil?
      key = klass.model_name.route_key
    end

    # ensure we got strs and not syms
    key = key.to_s

    @has_many = @has_many.merge({key => klass})
  end

  def self.client=(canary)
    Thread.current[:canary_client] = canary
  end

  def self.client
    Thread.current[:canary_client]
  end

  def canary
    self.class.client
  end

  def associations
    self.class.instance_variable_get('@has_many') || {}
  end

  # todo, remember to add parent association in parse
  def initialize(params = {})
    params.each do |attr, value|
      setter = attr.to_s.tr("-", "_")
      if klass = self.associations[setter]
        self.public_send("#{setter}=", klass.parse(value))
      else
        self.public_send("#{setter}=", value)
      end
    end if params
  end

  def attributes
    Hash[attr_accessors.map { |k| [k, send(k)] }]
  end

  # TODO: handle collections
  # for now this is distinct from the Canary#wrap code in so far
  # that nested collections aren't
  # expected to have cursors?
  def self.parse(attr, canary = nil)
    self.client ||= canary
    if attr.is_a? Array
      attr.map { |params| self.new(params) }
    else
      self.new(attr)
    end
  end
end

