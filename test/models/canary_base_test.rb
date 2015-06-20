require 'test_helper'

class CanaryBaseTest < ActiveSupport::TestCase
  describe "CanaryBase#initialize" do

    it "should handle simple hashes correctly" do
      klass = Class.new(CanaryBase) do
        attr_params :param1, :param2
      end

      hsh_sym = {:param1 => "test1", :param2 => "test2"}
      obj = klass.new(hsh_sym)
      assert_equal hsh_sym, obj.attributes
      assert obj.param1
      assert obj.param2

      # we also take strings as keys
      hsh_str = {"param1" => "test1", "param2" => "test2"}
      obj_str = klass.new(hsh_str)

      # strings get parsed but spat out as sym
      assert_equal hsh_sym, obj_str.attributes
      assert obj_str.param1
      assert obj_str.param2

    end

    it "should only handle whitelisted keys" do
      klass = Class.new(CanaryBase) do
        attr_params :param1
      end

      hsh = {:param1 => "test1", :param2 => "nope"}
      obj = klass.new(hsh)
      assert_not_equal obj.attributes, hsh
      assert obj.param1

      assert_raises(NoMethodError) do 
        obj.param2
      end

    end

    it "should handle hash keys with dashes" do
      klass = Class.new(CanaryBase) do
        attr_params :heartbeat_at, :an_arbitrary_name
      end

      hsh = { "heartbeat-at" => "test1", "an-arbitrary-name" => "test2" }

      obj = klass.new(hsh)
      assert obj.heartbeat_at
      assert obj.an_arbitrary_name
      assert_equal "test1", obj.attributes[:heartbeat_at]
    end

    it "should handle associations" do
      test_association_class = Class.new(CanaryBase) do
        attr_params :sub_param1
        def self.name
          "many_object"
        end
      end

      klass = Class.new(CanaryBase) do
        attr_params :param1, :many_objects
        has_many test_association_class
      end

      hsh = { "param1" => "test1", 
              "many_objects" => { "sub_param1" => "test2" } }

      obj = klass.new(hsh)
      assert obj.param1
      assert obj.many_objects
      assert_equal "test2", obj.many_objects.sub_param1
    end

    it "should handle collections of associations" do
      test_association_class = Class.new(CanaryBase) do
        attr_params :sub_param1
        def self.name
          "many_object"
        end
      end

      klass = Class.new(CanaryBase) do
        attr_params :param1, :many_objects
        has_many test_association_class
      end

      hsh = { "param1" => "test1", 
              "many_objects" => [
                { "sub_param1" => "test2" },
                { "sub_param1" => "test3" }
      ]}

      obj = klass.new(hsh)
      assert obj.param1
      assert_equal obj.many_objects.size, 2
      assert_equal "test2", obj.many_objects[0].sub_param1
      assert_equal "test3", obj.many_objects[1].sub_param1
    end
  end

  describe "CanaryBase.parse" do
    it "should take collections" do
      klass = Class.new(CanaryBase) do
        attr_params :param1, :param2
      end

      hsh = {:param1 => "test1", :param2 => "test2"}
      obj = klass.parse(hsh)

      assert_equal "test1", obj.param1

      objects = klass.parse([hsh])
      assert_equal 1, objects.size
      assert_equal "test1", objects[0].param1
    end
  end

end
