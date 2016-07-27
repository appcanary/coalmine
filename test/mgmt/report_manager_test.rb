# == Schema Information
#
# Table name: log_bundle_vulnerabilities
#
#  id                    :integer          not null, primary key
#  bundle_id             :integer          not null
#  package_id            :integer          not null
#  bundled_package_id    :integer          not null
#  vulnerability_id      :integer          not null
#  vulnerable_package_id :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'test_helper'

class ReportManagerTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false

  after :each do
    DatabaseCleaner.clean
  end

  let(:account) { FactoryGirl.create(:account) }

  setup do
    @platform = "ruby"
  end

  test "entire LBV lifecyle" do

    # ############
    # SCENARIO ONE
    # A bundle is created with a vuln package
    # ############

    # let's create some packages
    # and mark one of them as being vulnerable
    vuln_pkgs_set_1 = FactoryGirl.create_list(:package, 5, :ruby)
    vuln_pkg_1 = vuln_pkgs_set_1.first

    vm = VulnerabilityManager.new(vuln_pkg_1.platform)

    vuln_1, error = vm.create({},
                              [{:package_name => vuln_pkg_1.name,
                                :patched_versions => ["> #{vuln_pkg_1.version}"]}])

    # making sure everything looks legit
    assert_equal 1, VulnerablePackage.count
    assert_equal 0, BundledPackage.count
    assert_equal 0, LogBundleVulnerability.count

    # then let's create a new bundle
    # and assign packages
    @bm = BundleManager.new(account)

    package_list = vuln_pkgs_set_1.map { |pkg| PackageBuilder.from_package(pkg) }
    pr, _ = PlatformRelease.validate(@platform)
    bundle, errors = @bm.create(pr, {}, package_list)

    # Creating the bundle with a vuln should trigger a log:

    assert_equal 1, bundle.vulnerable_packages.count
    assert_equal 1, LogBundleVulnerability.count


    # let's assert that the LBV is recording the right things
    log = LogBundleVulnerability.first
    assert_equal bundle.id, log.bundle_id
    assert_equal vuln_pkg_1.id, log.package_id
    assert_equal BundledPackage.where(:bundle_id => bundle.id,
                                      :package_id => vuln_pkg_1.id).pluck(:id)[0], log.bundled_package_id

    assert_equal vuln_1.id, log.vulnerability_id
    assert_equal vuln_1.vulnerable_dependencies.first.id, log.vulnerable_dependency_id
    assert_equal VulnerablePackage.where(:package_id => vuln_pkg_1.id).pluck(:id)[0], log.vulnerable_package_id


    # ############
    # SCENARIO TWO
    # A bundle with a vulnerable package is updated, but the vuln package
    # is kept in the bundle.
    # ############

    pkgs_set_2 = FactoryGirl.create_list(:package, 3, :ruby)
    vuln_pkgs_set_2 = [vuln_pkg_1] + pkgs_set_2

    package_list2 = vuln_pkgs_set_2.map { |pkg| PackageBuilder.from_package(pkg) }
    @bm.update_packages(bundle.id, package_list2)

    # the vulnerability has not changed, therefore only one LogBundleVuln
    assert_equal 1, bundle.vulnerable_packages.count
    assert_equal 1, LogBundleVulnerability.count
    assert_equal 0, LogBundlePatch.count

    # ##############
    # SCENARIO THREE
    #
    # A bundle with a vulnerable package is updated to have zero packages,
    # i.e. all packages are removed, and the problem is patched.
    #
    # The vulnerable package is then readded.
    #
    # From the perspective of the bundle, this is a new package.
    # From the perspective of the LBV, this should be a new warning -
    # you're vulnerable again!
  
    @bm.update_packages(bundle.id, [])

    assert_equal 0, bundle.packages.count
    assert_equal 1, LogBundlePatch.count
    package_list3 = vuln_pkgs_set_2.map { |pkg| PackageBuilder.from_package(pkg) }
    @bm.update_packages(bundle.id, package_list3)

    # we now see another LBV.
    assert_equal 2, LogBundleVulnerability.count
    assert_equal vuln_pkg_1.id, LogBundleVulnerability.last.package_id


    # #############
    # SCENARIO FOUR: 
    # A vulnerability that affects a package already in the bundle
    # gets created.
    # #############

    # pick a package already associated with our bundle, from above:
    vuln_pkg_2 = vuln_pkgs_set_2.last

    # mark it as vuln
    vm = VulnerabilityManager.new(vuln_pkg_2.platform)
    vuln_2, error = vm.create({},
                              [{:package_name => vuln_pkg_2.name,
                                :patched_versions => ["> #{vuln_pkg_2.version}"]}])

    # did we create another LBV?
    assert_equal 2, VulnerablePackage.count
    assert_equal 3, LogBundleVulnerability.where(:bundle_id => bundle.id).count

    second_log = LogBundleVulnerability.last

    assert_equal vuln_2.id, second_log.vulnerability_id
    
    # the bundle wasn't changed, and so nothing was patched
    assert_equal 1, LogBundlePatch.count


    # #############
    # SCENARIO FIVE
    # An existing bundle gets updated with a vulnerable package
    # ###############


    vuln_pkg_3 = FactoryGirl.create(:package, :ruby)
    vuln_3 = FactoryGirl.create(:vulnerability, :pkgs => [vuln_pkg_3])

    assert_equal 3, VulnerablePackage.count

    @bm.update_packages(bundle.id, [vuln_pkg_3].map { |pkg| PackageBuilder.from_package(pkg)})

    # we've created another LBV,
    # and we wiped out two vuln packages: vuln_pkg_1 and vuln_pkg_2

    assert_equal 4, LogBundleVulnerability.where(:bundle_id => bundle.id).count
    assert_equal 3, LogBundlePatch.where(:bundle_id => bundle.id).count
  end

  test "when a vuln gets edited and now affects a different set of packages, both LBV and LBP are generated" do
    pkg1_name = "fakemctest"
    pkg2_name = "fakemctest2"
  
    pkg1_set = 10.times.map do |i|
      FactoryGirl.create(:package, :ruby,
                         :name => pkg1_name,
                         :version => "1.0.#{i}")

    end

    pkg2_set = 10.times.map do |i|
      FactoryGirl.create(:package, :ruby,
                         :name => pkg2_name,
                         :version => "2.0.#{i}")

    end

    vm = VulnerabilityManager.new(Platforms::Ruby)

    vuln1, error = vm.create({},
                             [{:package_name => pkg1_name,
                               :patched_versions => ["> 1.0.1"]}])
    vuln2, error = vm.create({},
                             [{:package_name => pkg2_name,
                               :patched_versions => ["> 2.0.1"]}])
    assert_equal 4, VulnerablePackage.count
    
    # version = 1.0.1
    vuln_pkg1 = pkg1_set.second

    # version = 2.0.2
    notvuln_pkg2 = pkg2_set[2]


    @bm = BundleManager.new(account)
    package_list = [vuln_pkg1, notvuln_pkg2].map { |p| PackageBuilder.from_package(p) }

    pr, _ = PlatformRelease.validate(@platform)
    bundle, error = @bm.create(pr, {}, package_list)
    
    # one LBV thank you
    assert_equal 1, LogBundleVulnerability.count
    assert_equal 0, LogBundlePatch.count

    # okay so now we have all this new info coming in and
    # vuln_pkg1 is no longer vuln!

    VulnerabilityManager.new(vuln1.package_platform).update(vuln1.id, {}, [{:package_name => vuln_pkg1.name,
                                                                            :patched_versions => ["> 1.0.0"]}])
    assert_equal 1, LogBundlePatch.count
    assert_equal 1, LogBundleVulnerability.count # just to double check

    # whelp, and look at that, notvuln_pkg2 is now vulnerable!
    VulnerabilityManager.new(vuln2.package_platform).update(vuln2.id, {}, [{:package_name => notvuln_pkg2.name, :patched_versions => ["> 2.0.2"]}])
    
    assert_equal 2, LogBundleVulnerability.count
    assert_equal 1, LogBundlePatch.count # just to double check

  end
end
