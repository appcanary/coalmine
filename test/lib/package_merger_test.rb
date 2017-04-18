require 'test_helper'
class PackageMergerTest < ActiveSupport::TestCase
  it "should merge any duplicate packages" do
    pkg1 = FactoryGirl.create(:package)
    pkg2 = FactoryGirl.create(:package, name: pkg1.name, version: pkg1.version, platform: pkg1.platform, release: pkg1.release)
    random_pkgs = FactoryGirl.create_list(:package, 5, platform: pkg1.platform, release: pkg1.release)

    assert_equal 7, Package.count

    empty_bundle = FactoryGirl.create(:bundle)

    bundle_with_pkg1 = FactoryGirl.create(:bundle)
    bundle_with_pkg1.packages << pkg1
    bundle_with_pkg1.packages += random_pkgs

    bundle_with_pkg2 = FactoryGirl.create(:bundle)
    bundle_with_pkg2.packages << pkg2
    bundle_with_pkg2.packages += random_pkgs

    bundle_with_both = FactoryGirl.create(:bundle)
    bundle_with_both.packages << pkg1 << pkg2
    bundle_with_both.packages += random_pkgs
    assert_equal 7, bundle_with_both.bundled_packages.reload.count

    PackageMerger.merge_duplicate_packages!

    assert_equal 6, Package.count

    assert_equal [], empty_bundle.packages.reload.to_a
    assert_equal [], empty_bundle.bundled_packages

    assert_equal [pkg1].to_set + random_pkgs, bundle_with_pkg1.packages.reload.to_set
    assert_equal 6, bundle_with_pkg1.bundled_packages.reload.count

    assert_equal [pkg1].to_set + random_pkgs, bundle_with_pkg2.packages.reload.to_set
    assert_equal 6, bundle_with_pkg2.bundled_packages.reload.count

    assert_equal [pkg1].to_set + random_pkgs, bundle_with_both.packages.reload.to_set
    assert_equal 6, bundle_with_both.bundled_packages.reload.count
  end
end
