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
    vuln_pkg_set_1 = FactoryGirl.create_list(:ruby_package, 5)
    vuln_pkg_1 = vuln_pkg_set_1.first

    vuln_1, error = VulnerabilityManager.new.create(:package_names => [vuln_pkg_1.name],
                                           :package_platform => vuln_pkg_1.platform,
                                           :patched_versions => ["> #{vuln_pkg_1.version}"])

    # making sure everything looks legit
    assert_equal 1, VulnerablePackage.count
    assert_equal 0, BundledPackage.count
    assert_equal 0, LogBundleVulnerability.count

    # then let's create a new bundle
    # and assign packages
    @bm = BundleManager.new(account)

    bundle, errors = @bm.create({:platform => @platform}, vuln_pkg_set_1.map(&:to_simple_h))

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
    assert_equal VulnerablePackage.where(:package_id => vuln_pkg_1.id).pluck(:id)[0], log.vulnerable_package_id


    # ############
    # SCENARIO TWO
    # A bundle with a vulnerable package is updated, but the vuln package
    # is kept in the bundle.
    # ############

    pkgs_set_2 = FactoryGirl.create_list(:ruby_package, 3)
    vuln_pkgs_set_2 = [vuln_pkg_1] + pkgs_set_2

    @bm.update(bundle.id, vuln_pkgs_set_2.map(&:to_simple_h))

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
  
    @bm.update(bundle.id, [])

    assert_equal 0, bundle.packages.count
    assert_equal 1, LogBundlePatch.count

    @bm.update(bundle.id, vuln_pkgs_set_2.map(&:to_simple_h))

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
    vuln_2, error = VulnerabilityManager.new.create(:package_names => [vuln_pkg_2.name],
                                             :package_platform => vuln_pkg_2.platform,
                                             :patched_versions => ["> #{vuln_pkg_2.version}"])

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


    vuln_pkg_3 = FactoryGirl.create(:ruby_package)
    vuln_3 = FactoryGirl.create(:ruby_vulnerability, :packages => [vuln_pkg_3])

    assert_equal 3, VulnerablePackage.count

    @bm.update(bundle.id, [vuln_pkg_3].map(&:to_simple_h))

    # we've created another LBV,
    # and we wiped out two vuln packages: vuln_pkg_1 and vuln_pkg_2

    assert_equal 4, LogBundleVulnerability.where(:bundle_id => bundle.id).count
    assert_equal 3, LogBundlePatch.where(:bundle_id => bundle.id).count
  end

  test "when a vuln gets edited and now affects a different set of packages, both LBV and LBP are generated" do
    pkg1_name = "fakemctest"
    pkg2_name = "fakemctest2"
  
    pkg1_set = 10.times.map do |i|
      FactoryGirl.create(:ruby_package,
                         :name => pkg1_name,
                         :version => "1.0.#{i}")

    end

    pkg2_set = 10.times.map do |i|
      FactoryGirl.create(:ruby_package,
                         :name => pkg2_name,
                         :version => "2.0.#{i}")

    end


    vuln1, error = VulnerabilityManager.new.create(:package_names => [pkg1_name],
                                           :package_platform => Platforms::Ruby,
                                           :patched_versions => ["> 1.0.1"])
    vuln2, error = VulnerabilityManager.new.create(:package_names => [pkg2_name],
                                            :package_platform => Platforms::Ruby,
                                            :patched_versions => ["> 2.0.1"])
    assert_equal 4, VulnerablePackage.count
    
    # version = 1.0.1
    vuln_pkg1 = pkg1_set.second

    # version = 2.0.2
    notvuln_pkg2 = pkg2_set[2]


    @bm = BundleManager.new(account)
    bundle, error = @bm.create({:platform => @platform}, [vuln_pkg1.to_simple_h, notvuln_pkg2.to_simple_h])
    
    # one LBV thank you
    assert_equal 1, LogBundleVulnerability.count
    assert_equal 0, LogBundlePatch.count

    # okay so now we have all this new info coming in and
    # vuln_pkg1 is no longer vuln!

    VulnerabilityManager.new.update(vuln1.id, :patched_versions => ["> 1.0.0"])
    assert_equal 1, LogBundlePatch.count
    assert_equal 1, LogBundleVulnerability.count # just to double check

    # whelp, and look at that, notvuln_pkg2 is now vulnerable!
    VulnerabilityManager.new.update(vuln2.id, :patched_versions => ["> 2.0.2"])
    
    assert_equal 2, LogBundleVulnerability.count
    assert_equal 1, LogBundlePatch.count # just to double check

  end
end
