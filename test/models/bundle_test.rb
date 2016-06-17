# == Schema Information
#
# Table name: bundles
#
#  id         :integer          not null, primary key
#  account_id :integer
#  name       :string
#  path       :string
#  platform   :string
#  release    :string
#  last_crc   :integer
#  from_api   :boolean
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class BundleTest < ActiveSupport::TestCase
  it "should accurately find relevant vuln pkgs" do
    # let's populate some packages
    bundled_packages = FactoryGirl.create_list(:ruby_package, 6)
    other_packages = FactoryGirl.create_list(:ruby_package, 6)

    # create a bundle and populate some of the packages 
    b = FactoryGirl.create(:bundle, :platform => Platforms::Ruby)
    
    bundled_package_list = bundled_packages.map do |p|
      {name: p.name,
       version: p.version}
    end

    b = BundleManager.new(b.account).update(b.id, bundled_package_list)
    assert_equal 0, b.vulnerable_packages.count

    # and mark some of them as vuln
    # two of them in the bundle, and one outside
    (bundled_packages.sample(2) + other_packages.sample(1)).each do |vp|
      FactoryGirl.create(:vulnerability, 
                         :package_name => vp.name,
                         :package_platform => vp.platform,
                         :patched_versions => ["> #{vp.version}"],
                         :packages => [vp])
    end

    assert_equal 3, VulnerablePackage.count
    assert_equal 2, b.vulnerable_packages.count
  end
end
