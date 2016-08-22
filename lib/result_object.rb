module ResultObject
  class Result
    attr_accessor :data, :error
    def initialize(data, error = nil)
      raise ArgumentError.new('must provide either data or error') if data.nil? && error.nil?
      self.data = data
      self.error = error
    end

    def to_ary
      [data, error]
    end
  end
end
