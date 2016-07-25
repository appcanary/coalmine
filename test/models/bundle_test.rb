# == Schema Information
#
# Table name: bundles
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  name       :string
#  path       :string
#  platform   :string           not null
#  release    :string
#  last_crc   :integer
#  from_api   :boolean
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  valid_at   :datetime         not null
#  expired_at :datetime         default("infinity"), not null
#

require 'test_helper'

class BundleTest < ActiveSupport::TestCase
  it "should accurately find relevant vuln pkgs" do
    # let's populate some packages
    bundled_packages = FactoryGirl.create_list(:package, 6, :ruby)
    other_packages = FactoryGirl.create_list(:package, 6, :ruby)

    # create a bundle and populate some of the packages 
    b = FactoryGirl.create(:bundle, :platform => Platforms::Ruby)
    
    bundled_package_list = bundled_packages.map { |p| PackageBuilder.from_package(p) }
    b, error = BundleManager.new(b.account).update(b.id, bundled_package_list)
    assert_equal 0, b.vulnerable_packages.count

    # and mark some of them as vuln
    # two of them in the bundle, and one outside
    (bundled_packages.sample(2) + other_packages.sample(1)).each do |vp|
      FactoryGirl.create(:vulnerability, 
                         :pkgs => [vp])
    end

    assert_equal 3, VulnerablePackage.count
    assert_equal 2, b.vulnerable_packages.count
  end

  test "whether the packages= association performs a diff" do
    # purpose of this test is to ensure that the underlying
    # join association (BundlePackage)'s ids remain "stable"
    # if we update the parent association with some of the
    # same packages.
    bundle = FactoryGirl.create(:bundle, :platform => Platforms::Ruby)
    
    alpha_pkg_set = FactoryGirl.create_list(:package, 10, :ruby)
    beta_pkg_set = FactoryGirl.create_list(:package, 8, :ruby)
    beta_pkg_set = [alpha_pkg_set[0], 
                    alpha_pkg_set[1]] + beta_pkg_set

    # two sets of packages, where the beta set contains the 
    # first two packages from the alpha set

    assert_equal 0, BundledPackage.count
    bundle.packages = alpha_pkg_set

    first_two_ids = bundle.bundled_packages.limit(2).order("id ASC").map(&:id)
    last_id = bundle.bundled_packages.last.id

    # assign the beta set to packages
    bundle.packages = beta_pkg_set

    # bundled packages has for sure changed
    assert_not_equal last_id, bundle.packages.last.id

    # but the first two remain the same, since they were unchanged.
    assert_equal first_two_ids, bundle.bundled_packages.limit(2).order("id ASC").map(&:id)
  end
end
