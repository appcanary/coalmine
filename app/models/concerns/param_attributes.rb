module ParamAttributes
  extend ActiveSupport::Concern

  included do
    define_singleton_method(:attr_params) do |*params|
      @attr_params ||= []
      @attr_params.concat params
      attr_accessor(*params)
    end
  end

  class_methods do
    def has_many(klass, key = nil)
      @has_many ||= {}

      if key.nil?
        key = klass.model_name.route_key
      end

      # ensure we got strs and not syms
      key = key.to_s

      @has_many = @has_many.merge({key => klass})
    end

    # TODO: handle collections
    # for now this is distinct from the Canary#wrap code in so far
    # that nested collections aren't expected to have cursors


    def parse(attr, canary = nil)
      if canary
        self.client = canary
      end

      if attr.is_a? Array
        attr.map { |params| self.new(params) }
      else
        self.new(attr)
      end
    end

    def client=(canary)
      @canary = canary
    end

    def client
      @canary || Canary.new(nil)
    end

    def _attr_params
      @attr_params || []
    end

  end


  # TODO remember to add parent association
 
  def initialize(params = {})
    assoc = self.associations
    attrs = self.attr_params.map(&:to_s)
    params.each do |attr, value|
      setter = attr.to_s.tr("-", "_")
      if klass = assoc[setter]
        self.public_send("#{setter}=", klass.parse(value))
      elsif attrs.include?(setter)
        self.public_send("#{setter}=", value)
      end
    end if params
  end

  def attributes
    Hash[attr_params.map { |k| [k, send(k)] }]
  end


  def associations
    self.class.instance_variable_get('@has_many') || {}
  end


  def attr_params
    self.class.instance_variable_get('@attr_params') || []
  end

  protected

  def canary
    self.class.client
  end

end
