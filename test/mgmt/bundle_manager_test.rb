require 'test_helper'

class BundlerManagerTest < ActiveSupport::TestCase
  let(:account) { FactoryGirl.create(:account) }

  setup do
    lockfile = hydrate("gemcanary.gemfile.lock")
    @package_list = GemfileParser.parse(lockfile)
    @platform = "ruby"
  end

  # TODO: test side effects!

  it "should create bundles" do
    @bm = BundleManager.new(account)

    assert_equal 0, Bundle.count
    assert_equal 0, Package.count
    bundle = @bm.create({:platform => @platform}, @package_list)
    assert_equal 1, Bundle.count

    bundle = Bundle.first
    assert_equal @package_list.count, bundle.packages.count
  end

  it "should update bundles" do
    bundle = FactoryGirl.create(:bundle_with_packages, 
                                :platform => "ruby", 
                                :account_id => account.id)

    @bm = BundleManager.new(account)

    assert_not_equal @package_list.count, bundle.packages.count
    
    package_count = Package.count
    assert package_count > 0

    bundle = @bm.update(bundle.id, @package_list)
    assert_equal @package_list.count, bundle.packages.count

    assert_equal package_count + @package_list.count, Package.count
  end

  it "only updates bundle under your account" do
    user2 = FactoryGirl.create(:account)
    bundle = FactoryGirl.create(:bundle, 
                                :platform => "ruby", 
                                :account_id => user2.id)

    @bm = BundleManager.new(account)
    assert_raises ActiveRecord::RecordNotFound do
      bundle = @bm.update(bundle.id, @package_list)
    end
  end

  it "should rename packages" do
    bundle = FactoryGirl.create(:bundle, 
                                :account_id => account.id, 
                                :name => "wrong")
    
    @bm = BundleManager.new(account)
    bundle = @bm.update_name(bundle.id, "right")
    bundle = Bundle.find(bundle.id)

    assert_equal "right", bundle.name
  end

  it "should delete and archive the bundle" do
    bundle = FactoryGirl.create(:bundle, 
                                :account_id => account.id, 
                                :name => "wrong")
    
    assert_equal 1, Bundle.count
    @bm = BundleManager.new(account)

    assert_raises ActiveRecord::RecordNotFound do
      @bm.delete(bundle.id + 1)
    end

    @bm.delete(bundle.id)
    assert_equal 0, Bundle.count
  end

  it "if a bundle's packages are vulnerable, ensure we add a LogBundleVulnerability" do
    pkgs = FactoryGirl.create_list(:ruby_package, 5)
    vuln_pkg = pkgs.first

    vuln = VulnerabilityManager.new.create(:package_name => vuln_pkg.name,
                                           :package_platform => vuln_pkg.platform,
                                           :patched_versions => ["> #{vuln_pkg.version}"])

    assert_equal 1, VulnerablePackage.count
    assert_equal 0, BundledPackage.count
    assert_equal 0, LogBundleVulnerability.count

    @bm = BundleManager.new(account)

    bundle = @bm.create({:platform => @platform}, 
                        pkgs.map { |p| {name: p.name, version: p.version}})

    assert_equal 1, bundle.vulnerable_packages.count
    assert_equal 1, LogBundleVulnerability.count

    new_pkgs = FactoryGirl.create_list(:ruby_package, 3)
    updated_pkgs = [vuln_pkg] + new_pkgs

    @bm.update(bundle.id, 
               updated_pkgs.map { |p| {name: p.name, version: p.version}})

    # the vulnerability has not changed, so only one LogBundleVuln
    assert_equal 1, bundle.vulnerable_packages.count
    assert_equal 1, LogBundleVulnerability.count


  end
end
