# == Schema Information
#
# Table name: bundled_package_archives
#
#  id                 :integer          not null, primary key
#  bundled_package_id :integer          not null
#  bundle_id          :integer          not null
#  package_id         :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  valid_at           :datetime         not null
#  expired_at         :datetime         not null
#

require 'test_helper'

class BundledPackageArchiveTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false

  after :each do
    DatabaseCleaner.clean
  end

  test "whether bps get stored on deletion" do
    bundle = FactoryGirl.create(:bundle_with_packages)
    new_packages = FactoryGirl.create_list(:package, 5)

    old_pbundles = bundle.bundled_packages.reload.to_a
    assert_equal 0, BundledPackageArchive.count

    assert_equal Float::INFINITY, bundle.bundled_packages.first.expired_at

    # let's archive some bundled packages
    bundle.packages = new_packages

    assert_equal old_pbundles.count, BundledPackageArchive.count
    assert_equal false, BundledPackageArchive.where(:expired_at => Float::INFINITY).present?

    # the old pbundles should be the entire content of BPA
    bpa_arr = BundledPackageArchive.all.map { |bpa| [bpa.bundled_package_id, bpa.bundle_id, bpa.package_id, bpa.valid_at] }
    bp_arr = old_pbundles.map { |bp| [bp.id, bp.bundle_id, bp.package_id, bp.valid_at] }

    assert_equal Set.new(bp_arr), Set.new(bpa_arr)
  end

  test "retrieving the bundle as it was 2 revisions ago" do
    bundle = FactoryGirl.create(:bundle)

    # initial revision
    bundle.packages = FactoryGirl.create_list(:ruby_package, 5)
    first_rev = bundle.bundled_packages.reload.to_a
    assert_equal 0, BundledPackageArchive.count

    # second revision
    bundle.packages = FactoryGirl.create_list(:ruby_package, 5)
    second_rev = bundle.bundled_packages.reload.to_a
    assert_equal 5, BundledPackageArchive.count

    reference_t = second_rev.first.valid_at

    # 3rd revision includes some packages from 2nd
    bundle.packages = bundle.packages + FactoryGirl.create_list(:ruby_package, 5)

    # 4th revision
    bundle.packages = FactoryGirl.create_list(:ruby_package, 5)

    # we've had 3 prev revisions times 5 packages
    assert_equal 15, BundledPackageArchive.count
    assert_equal 3, BundledPackageArchive.revisions(bundle.id).count

    fetched_rev = BundledPackageArchive.as_of(reference_t).where(:bundle_id => bundle.id)
    assert_equal Set.new(second_rev.map(&:id)), Set.new(fetched_rev.map(&:id))

    # okay. Now let's give it a rando date
    # the following should only fetch us the first five packages
    # since the timestamp is set to before the validity of second_rev
    new_ref_t = Time.at(reference_t.to_f - 0.001)

    fetched_rev_2 = BundledPackageArchive.as_of(new_ref_t).where(:bundle_id => bundle.id)
    assert_equal Set.new(first_rev.map(&:id)), Set.new(fetched_rev_2.map(&:id))
  end
end
