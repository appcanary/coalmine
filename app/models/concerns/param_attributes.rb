module ParamAttributes
  extend ActiveSupport::Concern

  included do
    define_singleton_method(:attr_params) do |*params|
      @attr_params ||= []
      @attr_params.concat params
      attr_accessor(*params)
    end

    define_singleton_method(:attr_enforce_collection) do |*params|
      @attr_enforce_collection ||= []
      @attr_enforce_collection.concat params
    end
  end

  class_methods do
    # has many ALWAYS assumes a collection
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

      # if this is not a has_many
      # attrs being an array is technically
      # an error
      if attr.is_a? Array
        attr.map { |params| self.new(params) }
      elsif attr.nil?
        return nil
      else
        self.new(attr)
      end
    end

    # enforce that has_many always is
    # an array.
    def parse_many(attr, canary = nil)
      if canary
        self.client = canary
      end

      all_attrs = wrap_array(attr)
      all_attrs.map { |params| self.new(params) }
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

    def wrap_array(attr)
      if attr.nil?
        return []
      elsif !attr.is_a? Array
        return [attr]
      else
        return attr
      end
    end

  end


  # TODO remember to add parent association
 
  def initialize(input_params = {})
    coll_association = self.has_many_associations
    attrs = self.attr_params.map(&:to_s)
    must_be_coll = attr_enforce_collection_params.map(&:to_s)

    params = sanitize_param_keys(input_params)
    attrs.each do |setter|
      value = params[setter]
      if klass = coll_association[setter]
        self.public_send("#{setter}=", klass.parse_many(value))
      else

        if must_be_coll.include?(setter)
          self.public_send("#{setter}=", wrap_array(value))
        else
          self.public_send("#{setter}=", value)
        end

      end
    end
  end

  def attributes
    Hash[attr_params.map { |k| [k, send(k)] }]
  end


  def has_many_associations
    self.class.instance_variable_get('@has_many') || {}
  end

  def attr_enforce_collection_params
    self.class.instance_variable_get('@attr_enforce_collection') || []
  end



  def attr_params
    self.class.instance_variable_get('@attr_params') || []
  end

  protected

  def sanitize_param_keys(params = {})
    new_params = {}
    params.each_pair do |k, v|
      key = k.to_s.tr("-", "_")
      new_params[key] = v
    end
    new_params
  end
 
  def canary
    self.class.client
  end

  def wrap_array(args)
    self.class.wrap_array(args)
  end

end
