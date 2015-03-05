module Mocker
  extend ActiveSupport::Concern

  def initialize(opt = {})

    self.class.instance_eval("@mock_attrs").each do |attr, block|
      self.send("#{attr}=", block.call(self))
    end

    opt.each_pair do |attr, val|
      instance_variable_set("@#{attr}", val)
      define_singleton_method(attr) do
        instance_variable_get("@#{attr}")
      end

      define_singleton_method("#{attr}=") do |value|
        instance_variable_set("@#{attr}", value)
      end

    end
  end

  module ClassMethods
    def mock_attr(attr, &block)
      @mock_attrs ||= []
      @mock_attrs << [attr, block]
      define_method(attr) do
        instance_variable_get("@#{attr}")
      end

      define_method("#{attr}=") do |value|
        instance_variable_set("@#{attr}", value)
      end
    end

  end
end
