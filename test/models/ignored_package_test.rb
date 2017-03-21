# == Schema Information
#
# Table name: ignored_packages
#
#  id          :integer          not null, primary key
#  account_id  :integer          not null
#  user_id     :integer          not null
#  package_id  :integer          not null
#  bundle_id   :integer
#  criticality :integer
#  note        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  ignored_packages_by_account_package_bundle_ids  (account_id,package_id,bundle_id) UNIQUE
#  index_ignored_packages_on_account_id            (account_id)
#  index_ignored_packages_on_bundle_id             (bundle_id)
#  index_ignored_packages_on_package_id            (package_id)
#  index_ignored_packages_on_user_id               (user_id)
#

require 'test_helper'

class IgnoredPackageTest < ActiveSupport::TestCase
  let(:account) { FactoryGirl.create(:account) }
  let(:user) { FactoryGirl.create(:user, account: account) }
  let(:pkg) { FactoryGirl.create(:package) }
  let(:bundle) { FactoryGirl.create(:bundle, packages: [pkg]) }
  let(:query) { VulnQuery.new(account) }

  setup do
    @vuln = FactoryGirl.create(:vulnerability, pkgs: [pkg])
  end

  describe "ignore_package" do
    test "ignore_package works for a package/bundle combo" do
      assert_equal 0, IgnoredPackage.where(account: account).count
      assert_equal true, query.vuln_bundle?(bundle)

      IgnoredPackage.ignore_package(user, pkg, bundle, "note #1")

      assert_equal 1, IgnoredPackage.where(account: account).count
      assert_equal false, query.vuln_bundle?(bundle)
    end

    test "ignore_package works for a package globally" do
      bundle2 = FactoryGirl.create(:bundle, packages: [pkg])

      assert_equal 0, IgnoredPackage.where(account: account).count
      assert_equal true, query.vuln_bundle?(bundle)
      assert_equal true, query.vuln_bundle?(bundle2)

      IgnoredPackage.ignore_package(user, pkg, nil, "note #1")

      assert_equal 1, IgnoredPackage.where(account: account).count
      assert_equal false, query.vuln_bundle?(bundle)
      assert_equal false, query.vuln_bundle?(bundle2)
    end

    test "ignore_package only impacts the correct bundle when not global" do
      bundle2 = FactoryGirl.create(:bundle, packages: [pkg])

      assert_equal 0, IgnoredPackage.where(account: account).count
      assert_equal true, query.vuln_bundle?(bundle)
      assert_equal true, query.vuln_bundle?(bundle2)

      IgnoredPackage.ignore_package(user, pkg, bundle, "note #1")

      assert_equal 1, IgnoredPackage.where(account: account).count
      assert_equal false, query.vuln_bundle?(bundle)
      assert_equal true, query.vuln_bundle?(bundle2)
    end
  end

  describe "unignore_packages" do
    test "works for a package/bundle combo" do
      ignore = FactoryGirl.create(:ignored_package, account: account, user: user, bundle: bundle, package: pkg)

      assert_equal 1, IgnoredPackage.where(account: account).count
      assert_equal false, query.vuln_bundle?(bundle)

      IgnoredPackage.unignore_package(user, pkg, bundle)

      assert_equal 0, IgnoredPackage.where(account: account).count
      assert_equal true, query.vuln_bundle?(bundle)
    end

    test "works for a global package ignore" do
      ignore = FactoryGirl.create(:ignored_package, account: account, user: user, package: pkg)

      assert_equal 1, IgnoredPackage.where(account: account).count
      assert_equal false, query.vuln_bundle?(bundle)

      IgnoredPackage.unignore_package(user, pkg, nil)

      assert_equal 0, IgnoredPackage.where(account: account).count
      assert_equal true, query.vuln_bundle?(bundle)
    end
  end
end
