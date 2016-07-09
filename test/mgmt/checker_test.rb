require 'test_helper'

class CheckerTest < ActiveSupport::TestCase
  let(:account) { FactoryGirl.create(:account) }

  setup do
    lockfile = hydrate("gemcanary.gemfile.lock")
    @package_list = GemfileParser.parse(lockfile)
    @platform = "ruby"
  end

  it "should return LBV-subset of vulns when asked" do
    vuln_pkg_set = FactoryGirl.create_list(:ruby_package, 5)
    vuln_pkg = vuln_pkg_set.first

    vuln = VulnerabilityManager.new.create(:package_name => vuln_pkg.name,
                                           :package_platform => vuln_pkg.platform,
                                           :patched_versions => ["> #{vuln_pkg.version}"])


    @checker = Checker.new(account, {platform: @platform})

    lbvs = @checker.check(vuln_pkg_set.map(&:to_simple_h))

    assert_equal 1, lbvs.count
  end
end
