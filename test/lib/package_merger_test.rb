require 'test_helper'
class PackageMergerTest < ActiveSupport::TestCase
  it "should merge any duplicate packages" do
    pkg1 = FactoryGirl.create(:package)
    pkg2 = FactoryGirl.create(:package, name: pkg1.name, version: pkg1.version, platform: pkg1.platform, release: pkg1.release)

    assert_equal 2, Package.count

    empty_bundle = FactoryGirl.create(:bundle)

    bundle_with_pkg1 = FactoryGirl.create(:bundle)
    bundle_with_pkg1.packages << pkg1

    bundle_with_pkg2 = FactoryGirl.create(:bundle)
    bundle_with_pkg2.packages << pkg2

    bundle_with_both = FactoryGirl.create(:bundle)
    bundle_with_both.packages << pkg1 << pkg2

    PackageMerger.merge_duplicate_packages!

    assert_equal 1, Package.count
    assert_equal [], empty_bundle.packages.reload.to_a
    assert_equal [pkg1], bundle_with_pkg1.packages.reload.to_a
    assert_equal [pkg1], bundle_with_pkg2.packages.reload.to_a
    assert_equal [pkg1], bundle_with_both.packages.reload.to_a
  end
end
