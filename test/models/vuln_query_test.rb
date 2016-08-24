require 'test_helper'
require 'helpers/sql_counter'

class VulnQueryTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false

  after :each do
    DatabaseCleaner.clean
  end


  setup do
    SqlCounter.attach_to :active_record

    # let us suppose we have five packages
    @packages = FactoryGirl.create_list(:package, 5, :ruby)

    # two of which are vulnerable. pkg1 has two vulns, pkg2 one

    @vulnpkg1 = @packages[0]
    @vulnpkg2 = @packages[1]
    @not_vuln_packages = @packages[2..-1]

    @vuln1 = FactoryGirl.create(:vulnerability, :pkgs => [@vulnpkg1])
    @vuln2 = FactoryGirl.create(:vulnerability, :pkgs => [@vulnpkg1])

    @vuln3 = FactoryGirl.create(:vulnerability, :pkgs => [@vulnpkg2])

    assert_equal 3, Vulnerability.count
    assert_equal 3, VulnerablePackage.count

  end

  test "whether #from_packages returns the right result" do
    # great. now we regenerate a package query
    package_list = @packages.map { |p| Parcel.builder_from_package(p) }

    package_query = nil
    Package.transaction do
      package_query = PackageMaker.new(Platforms::Ruby, nil).find_or_create(package_list)
    end

    # and we throw it to VulnQuery. We expect to get back
    # exactly two packages.
    
    results = VulnQuery.from_packages(package_query).order(:id)
    assert_equal results, [@vulnpkg1, @vulnpkg2]

    # (as opposed to having three packages, 
    # i.e. vulnpkg1, vulnpkg1, vulnpkg2)

    # finally, we test to see whether the includes were...
    # included.

    assert_no_difference ->{ SqlCounter.count(Vulnerability) +  SqlCounter.count(VulnerableDependency)  } do
      results.first.vulnerabilities.map(&:title)
      results.second.upgrade_to
    end
  end

  test "wether #from bundle returns the right result" do
    @bundle = FactoryGirl.create(:bundle, :packages => @packages)

    results = VulnQuery.from_bundle(@bundle).order(:id)

    assert_equal results, [@vulnpkg1, @vulnpkg2]

    assert_no_difference ->{ SqlCounter.count(Vulnerability) + SqlCounter.count(VulnerableDependency) } do
      results.first.vulnerabilities.map(&:title)
      results.second.upgrade_to
    end

  end

  test "whether #from_patched_notifications does the right thing" do
    @bundle = FactoryGirl.create(:bundle, :packages => @packages)
    Bundle.transaction do
      rm = ReportMaker.new(@bundle.id)
      rm.on_bundle_change
    end

    assert_equal 3, LogBundleVulnerability.count
    EmailManager.queue_vuln_emails!

    assert_equal 3, Notification.count
    
    # no patches yet
    assert_equal 0, VulnQuery.from_patched_notifications(Notification).count


    # thing we're trying to test:
    # but we should see a vuln notification per LBV
    results = VulnQuery.from_vuln_notifications(Notification)
    assert_equal 3, results.count

    # trigger loading the objects into memory, which will
    # matter for the next assertion
    results.to_a

    assert_no_difference ->{ SqlCounter.count(Vulnerability) + SqlCounter.count(VulnerableDependency) + SqlCounter.count(Package) + SqlCounter.count(Bundle) } do
      results.group_by(&:vulnerability)
      results.first.package.upgrade_to
      results.last.bundle.name
    end

    # ----------- 
    # time to generate some LBPs
    package_list = @not_vuln_packages.map { |p| Parcel.builder_from_package(p) }
    r = BundleManager.new(@bundle.account).update_packages(@bundle.id, package_list)

    assert_equal 3, LogBundlePatch.count
    # generate patch notifications
    EmailManager.queue_patched_emails!
    
    results = VulnQuery.from_patched_notifications(Notification)
    assert_equal 3, results.size

    # trigger loading the objects into memory, which will
    # matter for the next assertion

    results.to_a

    assert_no_difference ->{ SqlCounter.count(Vulnerability) + SqlCounter.count(VulnerableDependency) + SqlCounter.count(Package) + SqlCounter.count(Bundle) } do
      results.group_by(&:vulnerability)
      results.first.package.upgrade_to
      results.last.bundle.name
    end


  end
end
