# == Schema Information
#
# Table name: ignores
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
#  index_ignores_on_account_id                               (account_id)
#  index_ignores_on_account_id_and_bundle_id_and_package_id  (account_id,bundle_id,package_id) UNIQUE
#  index_ignores_on_bundle_id                                (bundle_id)
#  index_ignores_on_package_id                               (package_id)
#  index_ignores_on_user_id                                  (user_id)
#

require 'test_helper'

class IgnoreTest < ActiveSupport::TestCase
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
      assert_equal 0, Ignore.where(account: account).count
      assert_equal true, query.vuln_bundle?(bundle)

      Ignore.ignore_package(user, pkg, bundle, "note #1")

      assert_equal 1, Ignore.where(account: account).count
      assert_equal false, query.vuln_bundle?(bundle)
    end

    test "ignore_package works for a package globally" do
      bundle2 = FactoryGirl.create(:bundle, packages: [pkg])

      assert_equal 0, Ignore.where(account: account).count
      assert_equal true, query.vuln_bundle?(bundle)
      assert_equal true, query.vuln_bundle?(bundle2)

      Ignore.ignore_package(user, pkg, nil, "note #1")

      assert_equal 1, Ignore.where(account: account).count
      assert_equal false, query.vuln_bundle?(bundle)
      assert_equal false, query.vuln_bundle?(bundle2)
    end

    test "ignore_package only impacts the correct bundle when not global" do
      bundle2 = FactoryGirl.create(:bundle, packages: [pkg])

      assert_equal 0, Ignore.where(account: account).count
      assert_equal true, query.vuln_bundle?(bundle)
      assert_equal true, query.vuln_bundle?(bundle2)

      Ignore.ignore_package(user, pkg, bundle, "note #1")

      assert_equal 1, Ignore.where(account: account).count
      assert_equal false, query.vuln_bundle?(bundle)
      assert_equal true, query.vuln_bundle?(bundle2)
    end
  end

  describe "unignore_packages" do
    test "works for a package/bundle combo" do
      ignore = FactoryGirl.create(:ignore, account: account, user: user, bundle: bundle, package: pkg)

      assert_equal 1, Ignore.where(account: account).count
      assert_equal false, query.vuln_bundle?(bundle)

      Ignore.unignore_package(user, pkg, bundle)

      assert_equal 0, Ignore.where(account: account).count
      assert_equal true, query.vuln_bundle?(bundle)
    end

    test "works for a global package ignore" do
      ignore = FactoryGirl.create(:ignore, account: account, user: user, package: pkg)

      assert_equal 1, Ignore.where(account: account).count
      assert_equal false, query.vuln_bundle?(bundle)

      Ignore.unignore_package(user, pkg, nil)

      assert_equal 0, Ignore.where(account: account).count
      assert_equal true, query.vuln_bundle?(bundle)
    end
  end
end
