require "test_helper"

class BundlePresenterTest < ActiveSupport::TestCase
  let(:account) { FactoryGirl.create(:account) }
  let(:user) { FactoryGirl.create(:user, account: account) }
  let(:pkg) { FactoryGirl.create(:package) }
  let(:bundle) { FactoryGirl.create(:bundle, packages: [pkg], account: account) }

  test "ignored_packages simplest case works" do
    vuln = FactoryGirl.create(:vulnerability, pkgs: [pkg])

    # we start off with no ignores
    assert_equal 0, IgnoredPackage.where(account: account).count

    query = VulnQuery.new(account)
    bp = BundlePresenter.new(query, bundle)

    assert_equal 0, bp.ignored_packages.count

    # add an ignore for this package/bundle combo
    IgnoredPackage.ignore_package(user, pkg, bundle, "note #1")
    assert_equal 1, IgnoredPackage.where(account: account).count

    # make a new presenter, bc we cache things in it
    bp = BundlePresenter.new(query, bundle)
    assert_equal 1, bp.ignored_packages.count
    assert_equal 1, bp.ignored_packages.first.vuln_count
  end

  test "ignored_packages gets the correct vuln_count" do
    pkg2 = FactoryGirl.create(:package)
    bundle = FactoryGirl.create(:bundle, packages: [pkg, pkg2], account: account)

    vuln1 = FactoryGirl.create(:vulnerability, pkgs: [pkg])
    vuln2 = FactoryGirl.create(:vulnerability, pkgs: [pkg, pkg2])

    assert_equal 0, IgnoredPackage.where(account: account).count
    IgnoredPackage.ignore_package(user, pkg, bundle, "note #1")
    assert_equal 1, IgnoredPackage.where(account: account).count

    query = VulnQuery.new(account)
    bp = BundlePresenter.new(query, bundle)

    assert_equal 1, bp.ignored_packages.count
    assert_equal 2, bp.ignored_packages.first.vuln_count

    IgnoredPackage.ignore_package(user, pkg2, bundle, "note #2")
    assert_equal 2, IgnoredPackage.where(account: account).count

    bp = BundlePresenter.new(query, bundle)
    assert_equal 2, bp.ignored_packages.count

    bp.ignored_packages.each do |ip|
      if ip.note == "note #1"
        assert 2, ip.vuln_count
      else
        assert 1, ip.vuln_count
      end
    end
  end

  test "ignored_packages works with global ignores" do
    vuln = FactoryGirl.create(:vulnerability, pkgs: [pkg])

    # we start off with no ignores
    assert_equal 0, IgnoredPackage.where(account: account).count

    query = VulnQuery.new(account)
    bp = BundlePresenter.new(query, bundle)

    assert_equal 0, bp.ignored_packages.count

    # add an ignore for this package in a global context
    IgnoredPackage.ignore_package(user, pkg, nil, "note #1")
    assert_equal 1, IgnoredPackage.where(account: account).count

    # make a new presenter, bc we cache things in it
    bp = BundlePresenter.new(query, bundle)
    assert_equal 1, bp.ignored_packages.count
    assert_equal 1, bp.ignored_packages.first.vuln_count
  end

  test "ignored_packages gets the correct vuln_count with global ignores" do
    pkg2 = FactoryGirl.create(:package)
    bundle = FactoryGirl.create(:bundle, packages: [pkg, pkg2], account: account)

    vuln1 = FactoryGirl.create(:vulnerability, pkgs: [pkg])
    vuln2 = FactoryGirl.create(:vulnerability, pkgs: [pkg, pkg2])

    assert_equal 0, IgnoredPackage.where(account: account).count
    IgnoredPackage.ignore_package(user, pkg, nil, "note #1")
    assert_equal 1, IgnoredPackage.where(account: account).count

    query = VulnQuery.new(account)
    bp = BundlePresenter.new(query, bundle)

    assert_equal 1, bp.ignored_packages.count
    assert_equal 2, bp.ignored_packages.first.vuln_count

    IgnoredPackage.ignore_package(user, pkg2, nil, "note #2")
    assert_equal 2, IgnoredPackage.where(account: account).count

    bp = BundlePresenter.new(query, bundle)
    assert_equal 2, bp.ignored_packages.count

    bp.ignored_packages.each do |ip|
      if ip.note == "note #1"
        assert 2, ip.vuln_count
      else
        assert 1, ip.vuln_count
      end
    end
  end

  test "ignored_packages doesn't show packages belong to another account" do
    account2 = FactoryGirl.create(:account)
    user2 = FactoryGirl.create(:user, account: account2)
    bundle2 = FactoryGirl.create(:bundle, packages: [pkg], account: account2)

    vuln = FactoryGirl.create(:vulnerability, pkgs: [pkg])

    assert_equal 0, IgnoredPackage.where(account: account2).count
    IgnoredPackage.ignore_package(user2, pkg, nil, "note #1")
    assert_equal 1, IgnoredPackage.where(account: account2).count

    # User1 still has no ignores in the presenter
    query = VulnQuery.new(account)
    bp = BundlePresenter.new(query, bundle)

    assert_equal 0, bp.ignored_packages.count
  end
end
