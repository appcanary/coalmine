require 'test_helper'

class LogResolutionTest < ActiveSupport::TestCase
  let(:account) { FactoryGirl.create(:account) }
  let(:user) { FactoryGirl.create(:user, account: account) }
  let(:pkg) { FactoryGirl.create(:package) }
  let(:bundle) { FactoryGirl.create(:bundle, :packages => [pkg]) }

  it "should correctly handle the same package idempotently" do
    # suppose we have a vuln
    vuln = FactoryGirl.create(:vulnerability, :pkgs => [pkg])
    
    # and we mark it as resolved
    assert_equal 0, LogResolution.where(account: account).size
    LogResolution.resolve_package(user, pkg)
    assert_equal 1, LogResolution.where(account: account).size

    assert_equal 0, VulnQuery.new(account).from_bundle(bundle).size

    # but then a new vuln comes along on the same package
    vuln2 = FactoryGirl.create(:vulnerability, :pkgs => [pkg])
    assert_equal 1, VulnQuery.new(account).from_bundle(bundle).size

    assert_nothing_raised do
      LogResolution.resolve_package(user, pkg.reload)
    end

    assert_equal 2, LogResolution.where(account: account).size
  end
end
