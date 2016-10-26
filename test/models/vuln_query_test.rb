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
    @packages = FactoryGirl.create_list(:package, 10, :ruby)

    # two of which are vulnerable. pkg1 has two vulns, pkg2 one

    @vulnpkg1 = @packages[0]
    @vulnpkg2 = @packages[1]

    @vulnpkg3 = @packages[2]
    @vulnpkg4 = @packages[3]

    @not_vuln_packages = @packages[4..-1]

    @vuln1 = FactoryGirl.create(:vulnerability, :pkgs => [@vulnpkg1])
    @vuln2 = FactoryGirl.create(:vulnerability, :pkgs => [@vulnpkg1])

    @vuln3 = FactoryGirl.create(:vulnerability, :pkgs => [@vulnpkg2])

    # ---- vulns that lack patches

    @patchless_vuln = FactoryGirl.create(:vulnerability, :ruby, :patchless, :pkgs => [@vulnpkg3], :deps => [])
    
    @patchless_vuln_w_unaffected = FactoryGirl.create(:vulnerability, :ruby, :patchless, :pkgs => [@vulnpkg4], :deps => [])
    vd = @patchless_vuln_w_unaffected.vulnerable_dependencies.first
    vd.unaffected_versions = ["~> 1.2.3"]
    vd.save!

    assert_equal 5, Vulnerability.count
    assert_equal 5, VulnerablePackage.count

  end

  test "whether #from_packages returns the right result" do
    # great. now we regenerate a package query
    package_list = @packages.map { |p| Parcel.builder_from_package(p) }

    package_query = nil
    Package.transaction do
      package_query = PackageMaker.new(Platforms::Ruby, nil).find_or_create(package_list)
    end

    # and we throw it to VulnQuery. We expect to get back
    # exactly four packages.
    
    results = VulnQuery.from_packages(package_query).order(:id)
    assert_equal results, [@vulnpkg1, @vulnpkg2, @vulnpkg3, @vulnpkg4]

    # (as opposed to having repeat packages, 
    # i.e. vulnpkg1, vulnpkg1, vulnpkg2, etc)

    # finally, we test to see whether the includes were...
    # included.

    assert_no_difference ->{ SqlCounter.count(Vulnerability) +  SqlCounter.count(VulnerableDependency)  } do
      results.first.vulnerabilities.map(&:title)
      results.second.upgrade_to
    end
  end

  test "whether #from bundle returns the right result" do
    @bundle = FactoryGirl.create(:bundle, :packages => @packages)

    results = VulnQuery.from_bundle(@bundle).order(:id)

    assert_equal results, [@vulnpkg1, @vulnpkg2, @vulnpkg3, @vulnpkg4]

    assert_no_difference ->{ SqlCounter.count(Vulnerability) + SqlCounter.count(VulnerableDependency) } do
      results.first.vulnerabilities.map(&:title)
      results.second.upgrade_to
    end

  end

  test "whether vuln_server? does the right thing" do
    bundle = FactoryGirl.create(:bundle, :packages => @packages)
    account = bundle.account
    server = FactoryGirl.create(:agent_server, :account => account,
                                :bundles => [bundle])


    assert_equal true, VulnQuery.new(account).vuln_server?(server)
    account.notify_everything = true
    assert_equal true, VulnQuery.new(account).vuln_server?(server)
  end

  test "whether instance from_bundle does the right thing" do
    bundle = FactoryGirl.create(:bundle, :packages => @packages)
    account = bundle.account

    results = VulnQuery.new(account).from_bundle(bundle).order(:id)
    assert_equal results, [@vulnpkg1, @vulnpkg2, @vulnpkg4]

    account.notify_everything = true

    results = VulnQuery.new(account).from_bundle(bundle).order(:id)
    assert_equal results, [@vulnpkg1, @vulnpkg2, @vulnpkg3, @vulnpkg4]
  end

  test "whether #from_patched_notifications does the right thing" do
    @bundle = FactoryGirl.create(:bundle, :packages => @packages)
    Bundle.transaction do
      rm = ReportMaker.new(@bundle.id)
      rm.on_bundle_change
    end

    assert_equal 5, LogBundleVulnerability.count
    EmailManager.queue_vuln_emails!

    # only four of the vulns are patcheable,
    # see email manager test
    assert_equal 4, Notification.count
    
    # no patches yet
    assert_equal 0, VulnQuery.from_patched_notifications(Notification).count


    # thing we're trying to test:
    # but we should see a vuln notification per patcheable LBV
    results = VulnQuery.from_vuln_notifications(Notification)
    assert_equal 4, results.count

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

    assert_equal 5, LogBundlePatch.count
    # generate patch notifications
    EmailManager.queue_patched_emails!
    
    results = VulnQuery.from_patched_notifications(Notification)
    assert_equal 4, results.size

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
