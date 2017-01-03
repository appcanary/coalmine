require 'test_helper'
require 'helpers/sql_counter'

class VulnQueryTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false

  after :each do
    DatabaseCleaner.clean
  end


  # TLDR: 
  # vulnpkg1 has 2 vulns
  # vulnpkg2 has 1 vuln
  # vulnpkg3 has 1 vuln, with no way to remediate it
  # vulnpkg4 has 1 vuln, with no patch but with an unaffected version
  #
  # a bundle with @packages is "affected" by
  # [@vulnpkg1, @vulnpkg2, @vulnpkg3, @vulnpkg4]
  # and is "patchable" with
  # [@vulnpkg1, @vulnpkg2, @vulnpkg4]

  setup do
    SqlCounter.attach_to :active_record

    # let us suppose we have ten packages
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
    @patchless_vulnpkg = @vulnpkg3
    
    @patchless_vuln_w_unaffected = FactoryGirl.create(:vulnerability, :ruby, :patchless, :pkgs => [@vulnpkg4], :deps => [])
    vd = @patchless_vuln_w_unaffected.vulnerable_dependencies.first
    vd.unaffected_versions = ["~> 1.2.3"]
    vd.save!

    assert_equal 5, Vulnerability.count
    assert_equal 5, VulnerablePackage.count
  end

  test "whether #from_packages returns only affected packages" do
    # first we generate a package_list from @packages
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

  test "whether #affected_from bundle returns the right result" do
    @bundle = FactoryGirl.create(:bundle, :packages => @packages)

    results = VulnQuery.affected_from_bundle(@bundle).order(:id)

    assert_equal results, [@vulnpkg1, @vulnpkg2, @vulnpkg3, @vulnpkg4]

    assert_no_difference ->{ SqlCounter.count(Vulnerability) + SqlCounter.count(VulnerableDependency) } do
      results.first.vulnerabilities.map(&:title)
      results.second.upgrade_to
    end

  end

  test "whether #patchable_from bundle ignores patchless packages" do
    @bundle = FactoryGirl.create(:bundle, :packages => @packages)

    results = VulnQuery.patchable_from_bundle(@bundle).order(:id)

    # vulnpkg3 is tied to @patchless_vuln so we should not see it
    assert_equal results, [@vulnpkg1, @vulnpkg2, @vulnpkg4]

    assert_no_difference ->{ SqlCounter.count(Vulnerability) + SqlCounter.count(VulnerableDependency) } do
      results.first.vulnerabilities.map(&:title)
      results.second.upgrade_to
    end

  end

  test "whether vuln_server? diagnoses servers properly" do
    # create a bundle and associate it with a server
    account = FactoryGirl.create(:account)
    vulnbundle = FactoryGirl.create(:bundle, :account => account,
                                    :packages => @packages)

    safebundle = FactoryGirl.create(:bundle, :account => account,
                                    :packages => @not_vuln_packages)

    
    server = FactoryGirl.create(:agent_server, :account => account,
                                :bundles => [safebundle])


    # by default, we only notify for patchable stuff
    assert_equal false, VulnQuery.new(account).vuln_server?(server)
    account.notify_everything = true
    assert_equal false, VulnQuery.new(account).vuln_server?(server)

    # reset the notify_everything flag, add the vuln bundle
    account.notify_everything = false
    server.bundles << vulnbundle

    assert_equal true, VulnQuery.new(account).vuln_server?(server)
    account.notify_everything = true
    assert_equal true, VulnQuery.new(account).vuln_server?(server)
  end

  test "whether vuln_server? ignores unpatcheable vulns" do
    unpatchable_bundle = FactoryGirl.create(:bundle,
                                            :packages => [@patchless_vulnpkg])
    account = unpatchable_bundle.account
    unpatchable_server = FactoryGirl.create(:agent_server, :account => account,
                                            :bundles => [unpatchable_bundle])


    assert_equal false, VulnQuery.new(account).vuln_server?(unpatchable_server)
    account.notify_everything = true
    assert_equal true, VulnQuery.new(account).vuln_server?(unpatchable_server)

  end

  test "whether vuln_bundle? diagnoses bundles correctly" do
    account = FactoryGirl.create(:account)
    vulnbundle = FactoryGirl.create(:bundle, :account => account,
                                    :packages => @packages)

    safebundle = FactoryGirl.create(:bundle, :account => account,
                                    :packages => @not_vuln_packages)


    assert_equal true, VulnQuery.new(account).vuln_bundle?(vulnbundle)
    account.notify_everything = true
    assert_equal true, VulnQuery.new(account).vuln_bundle?(vulnbundle)

    # and now for the safe bundle we reset
    account.notify_everything = false

    assert_equal false, VulnQuery.new(account).vuln_bundle?(safebundle)
    account.notify_everything = true
    assert_equal false, VulnQuery.new(account).vuln_bundle?(safebundle)
  end

   test "whether vuln_bundle? ignores unpatchable vulns" do
    bundle = FactoryGirl.create(:bundle, :packages => [@patchless_vulnpkg])
    account = bundle.account

    assert_equal false, VulnQuery.new(account).vuln_bundle?(bundle)
    account.notify_everything = true
    assert_equal true, VulnQuery.new(account).vuln_bundle?(bundle)
  end


  test "whether instance from_bundle correctly reports vuln pkgs" do
    bundle = FactoryGirl.create(:bundle, :packages => @packages)
    account = bundle.account

    # by default we do not care about patchless
    results = VulnQuery.new(account).from_bundle(bundle).order(:id)
    assert_equal [@vulnpkg1, @vulnpkg2, @vulnpkg4], results

    account.notify_everything = true

    results = VulnQuery.new(account).from_bundle(bundle).order(:id)
    assert_equal [@vulnpkg1, @vulnpkg2, @vulnpkg3, @vulnpkg4], results

  end

  test "whether #from_patched_notifications returns correct LBV/LBPs" do
 
    # first we generate some LBVs.
    # we create a vuln bundle and set off a report,
    # then we create notifications from the LBVs

    @bundle = FactoryGirl.create(:bundle, :packages => @packages)
    Bundle.transaction do
      rm = LogMaker.new
      rm.on_bundle_change(@bundle.id)
    end

    assert_equal 5, LogBundleVulnerability.count
    EmailManager.queue_vuln_emails!

    # only four of the vulns are patcheable. rn we have
    # hard coded ignore unpatchable vulns
    # see email manager test
    assert_equal 4, Notification.count
    
    # no patches yet, so no LBVs to return
    assert_equal 0, VulnQuery.from_patched_notifications(Notification.all).count


    # thing we're trying to test:
    # we should see one LBV per patcheable notification
    results = VulnQuery.from_vuln_notifications(Notification.all)
    vuln_log_count = results.count
    assert_equal 4, vuln_log_count

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
    # we update the bundle so we "patch" it, by removing the vuln pkgs
    package_list = @not_vuln_packages.map { |p| Parcel.builder_from_package(p) }
    r = BundleManager.new(@bundle.account).update_packages(@bundle.id, package_list)

    assert_equal 5, LogBundlePatch.count
    # generate patch notifications
    EmailManager.queue_patched_emails!
    
    results = VulnQuery.from_patched_notifications(Notification.all)
    patched_log_count = results.count
    assert_equal 4, patched_log_count

    # we have 4 vulns before, so they better line up
    assert_equal vuln_log_count, patched_log_count

    # trigger loading the objects into memory, which will
    # matter for the next assertion

    results.to_a

    assert_no_difference ->{ SqlCounter.count(Vulnerability) + SqlCounter.count(VulnerableDependency) + SqlCounter.count(Package) + SqlCounter.count(Bundle) } do
      results.group_by(&:vulnerability)
      results.first.package.upgrade_to
      results.last.bundle.name
    end
  end

  test "whether instance from_bundle respects resolution logs" do
    account = FactoryGirl.create(:account)
    user = FactoryGirl.create(:user, :account => account)
    bundle = FactoryGirl.create(:bundle, :account => account,
                                :packages => @packages)

    # now we mark vulnpkg2 as resolved
    
    resolve_log = LogResolution.resolve_package(user, @vulnpkg2)

    results = VulnQuery.new(account).from_bundle(bundle).order(:id)

    # contrast with from_bundle test above: should ignore vulnpkg3
    # and now vulnpkg2
    assert_equal [@vulnpkg1, @vulnpkg4], results
  end

  test "whether vuln_bundle? respects resolution logs" do
    account = FactoryGirl.create(:account)
    user = FactoryGirl.create(:user, :account => account)

    bundle = FactoryGirl.create(:bundle, :account => account,
                                :packages => [@vulnpkg2])
    
    vq = VulnQuery.new(account)
    assert_equal true, vq.vuln_bundle?(bundle)
 
    # now we mark vulnpkg2 as resolved
    resolve_log = LogResolution.resolve_package(user, @vulnpkg2)

    assert_equal false, vq.vuln_bundle?(bundle)
  end


  test "whether vuln_server? respects resolution logs" do
    account = FactoryGirl.create(:account)
    user = FactoryGirl.create(:user, :account => account)

    bundle = FactoryGirl.create(:bundle, :account => account,
                                :packages => [@vulnpkg2])

    server = FactoryGirl.create(:agent_server, :account => account,
                       :bundles => [bundle])

    
    vq = VulnQuery.new(account)
    assert_equal true, vq.vuln_server?(server)
 
    # now we mark vulnpkg2 as resolved
    resolve_log = LogResolution.resolve_package(user, @vulnpkg2)

    assert_equal false, vq.vuln_server?(server)
  end


end
