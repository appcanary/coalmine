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
    vuln_pkg1 = vuln_pkg_set.first
    vuln_pkg2 = vuln_pkg_set.second

    vuln = VulnerabilityManager.new.create(:package_name => vuln_pkg1.name,
                                           :package_platform => vuln_pkg1.platform,
                                           :patched_versions => ["> #{vuln_pkg1.version}"])

    vuln2 = VulnerabilityManager.new.create(:package_name => vuln_pkg1.name,
                                            :package_platform => vuln_pkg1.platform,
                                            :patched_versions => ["> #{vuln_pkg1.version}"])



    vuln3 = VulnerabilityManager.new.create(:package_name => vuln_pkg2.name,
                                            :package_platform => vuln_pkg2.platform,
                                            :patched_versions => ["> #{vuln_pkg2.version}"])


    @checker = Checker.new(account, {platform: @platform})

    packages = @checker.check(vuln_pkg_set.map(&:to_simple_h))

    assert_equal 2, packages.count
    assert_equal 2, packages.first.vulnerabilities.count
    assert_equal 1, packages.second.vulnerabilities.count

  end
end
