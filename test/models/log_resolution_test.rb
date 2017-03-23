# == Schema Information
#
# Table name: log_resolutions
#
#  id                       :integer          not null, primary key
#  account_id               :integer          not null
#  user_id                  :integer          not null
#  package_id               :integer          not null
#  vulnerability_id         :integer          not null
#  vulnerable_dependency_id :integer          not null
#  note                     :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_log_resolutions_on_account_id                (account_id)
#  index_log_resolutions_on_package_id                (package_id)
#  index_log_resolutions_on_user_id                   (user_id)
#  index_log_resolutions_on_vulnerability_id          (vulnerability_id)
#  index_log_resolutions_on_vulnerable_dependency_id  (vulnerable_dependency_id)
#  index_logres_account_vulndeps                      (account_id,package_id,vulnerable_dependency_id) UNIQUE
#

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
