require 'test_helper'

class PackageManagerTest < ActiveSupport::TestCase
  it "should find or create packages accordingly" do
    p1 = FactoryGirl.create(:ruby_package)
    p2 = {:name => "foobarbaz", :kind => "rubygem", 
          :version => "1.0.0", :platform => "ruby"}

    package_list = [p2, {:name => p1.name, :version => p1.version}]

    assert_equal 1, Package.count

    @pm = PackageManager.new("ruby", nil)
    packages = @pm.find_or_create(package_list)
    assert_equal 2, packages.count
    assert_equal 2, Package.count
  end
end
