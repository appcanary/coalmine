require 'test_helper'

class CheckerTest < ActiveSupport::TestCase
  let(:account) { FactoryGirl.create(:account) }

  setup do
    lockfile = hydrate("gemcanary.gemfile.lock")
    @package_list = GemfileParser.parse(lockfile)
    @platform = "ruby"
    passthru_parser = Class.new do def self.parse(list) list; end; end
    Platforms.stubs(:parser_for).with(@platform).returns(passthru_parser) 
  end

  it "should return LBV-subset of vulns when asked" do
    vuln_pkg_set = FactoryGirl.create_list(:package, 5, :ruby)
    vuln_pkg1 = vuln_pkg_set.first
    vuln_pkg2 = vuln_pkg_set.second

    FactoryGirl.create(:vulnerability, :ruby, :pkgs => [vuln_pkg1])
    FactoryGirl.create(:vulnerability, :ruby, :pkgs => [vuln_pkg1])
    FactoryGirl.create(:vulnerability, :ruby, :pkgs => [vuln_pkg2])

    @checker = Checker.new(account, {platform: @platform})

    packages = @checker.check(vuln_pkg_set.map { |p| PackageBuilder.from_package(p)})

    assert_equal 2, packages.count
    assert_equal 2, packages.first.vulnerabilities.count
    assert_equal 1, packages.second.vulnerabilities.count
  end
end
