module TrackAttributes
  extend ActiveSupport::Concern

  included do
    # define_singleton_method(:attr_reader) do |*params|
    #   @attr_readers ||= []
    #   @attr_readers.concat params
    #   super(*params)
    # end

    # define_singleton_method(:attr_writer) do |*params|
    #   @attr_writers ||= []
    #   @attr_writers.concat params
    #   super(*params)
    # end

    define_singleton_method(:attr_params) do |*params|
      @attr_accessors ||= []
      @attr_accessors.concat params
      attr_accessor(*params)
    end

    define_singleton_method(:map_key) do |hsh|
      @map_key ||= {}
      @map_key = @map_key.merge(hsh)
    end
  end

  def attr_readers
    self.class.instance_variable_get('@attr_readers')
  end

  def attr_writers
    self.class.instance_variable_get('@attr_writers')
  end

  def attr_accessors
    self.class.instance_variable_get('@attr_accessors')
  end

  def map_key
    self.class.instance_variable_get('@map_key') || {}
  end

end
