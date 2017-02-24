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
# Indexes
#
#  idx_bundled_package_id_ar                     (bundled_package_id)
#  index_bundled_package_archives_on_bundle_id   (bundle_id)
#  index_bundled_package_archives_on_expired_at  (expired_at)
#  index_bundled_package_archives_on_package_id  (package_id)
#  index_bundled_package_archives_on_valid_at    (valid_at)
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
    revision_ids = []

    # initial revision: ids 1, 2, 3, 4, 5
    bundle.packages = FactoryGirl.create_list(:package, 5, :ruby)
    revision_ids << bundle.bundled_packages.reload.pluck(:package_id)
    assert_equal 0, BundledPackageArchive.count

    # second revision: ids 6, 7, 8, 9, 10
    # 5 bp put into archive
    bundle.packages = FactoryGirl.create_list(:package, 5, :ruby)
    revision_ids << bundle.bundled_packages.reload.pluck(:package_id)
    assert_equal 5, BundledPackageArchive.count

    # 3rd revision: we just add packages
    # ids: 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
    # nothing gets deleted, so nothing gets added to BPA
    bundle.packages = bundle.packages + FactoryGirl.create_list(:package, 5, :ruby)
    revision_ids << bundle.bundled_packages.reload.pluck(:package_id)
    assert_equal 5, BundledPackageArchive.count

    # 4th revision: we keep some, delete the rest, and add more
    # ids: 6, 7, 1, 2, 3, 4
    # 8 bp put into archive
    bundle.packages = bundle.packages[0..1] + Package.where("id < 5").order(:id)
    revision_ids << bundle.bundled_packages.reload.pluck(:package_id)
    assert_equal 13, BundledPackageArchive.count


    # 5th revision: we delete everything and add more
    # ids: 16, 17, 18, 19, 20
    # 6 bp put into archive
    bundle.packages = FactoryGirl.create_list(:package, 5, :ruby)
    revision_ids << bundle.bundled_packages.reload.pluck(:package_id)
    assert_equal 19, BundledPackageArchive.count


    revisions = BundledPackage.revisions(bundle.id)
    assert_equal 5, revisions.count

    # ---- now we test how well we can retrieve these revisions
    revisions.each_with_index do |r_at, i|
      assert_equal revision_ids[i].to_set, BundledPackage.as_of(r_at).pluck(:package_id).to_set
    end
  end
end
