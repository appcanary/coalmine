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

    it "should handle enforce_collection" do
      klass = Class.new(CanaryBase) do
        attr_params :heartbeat_at, :many_things
        attr_enforce_collection :many_things
      end

      hsh = { "heartbeat-at" => "test1", "many-things" => "foo" }

      obj = klass.new(hsh)
      assert obj.heartbeat_at
      assert_equal 1, obj.many_things.size
      assert_equal "foo", obj.many_things[0]

      hsh_missing = { }

      obj_missing = klass.new(hsh_missing)
      assert_equal false, obj_missing.many_things.nil?
      assert_equal 0, obj_missing.many_things.size
    end
  end

  describe "CanaryBase associations" do

    it "has many associations always return arrays" do
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
      assert obj.many_objects.present?
      assert_equal 1, obj.many_objects.size
      assert_equal test_association_class, obj.many_objects.first.class
      assert_equal "test2", obj.many_objects.first.sub_param1
    end

    it "has many associations should handle actual collections" do
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
      assert_equal test_association_class, obj.many_objects[0].class
      assert_equal "test2", obj.many_objects[0].sub_param1
      assert_equal "test3", obj.many_objects[1].sub_param1
    end

    it "when an association collection is empty, it should be []" do
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


      hsh_arr = { "param1" => "test1", 
              "many_objects" => [] 
      }

      obj_arr = klass.new(hsh_arr)
      assert obj_arr.param1
      assert_equal true, obj_arr.many_objects.empty?
      assert_not_equal nil, obj_arr.many_objects
      assert_equal 0, obj_arr.many_objects.size


      hsh_nil = { "param1" => "test1", 
              "many_objects" => nil 
      }

      obj_nil = klass.new(hsh_nil)
      assert obj_nil.param1
      assert_equal true, obj_nil.many_objects.empty?
      assert_not_equal nil, obj_nil.many_objects
      assert_equal 0, obj_nil.many_objects.size


      hsh_missing = { "param1" => "test1",}

      obj_missing = klass.new(hsh_missing)
      assert obj_missing.param1
      assert_equal true, obj_missing.many_objects.empty?
      assert_not_equal nil, obj_missing.many_objects
      assert_equal 0, obj_missing.many_objects.size

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
