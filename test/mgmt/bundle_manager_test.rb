require 'test_helper'

class BundlerManagerTest < ActiveSupport::TestCase
  let(:account) { FactoryGirl.create(:account) }

  setup do
    lockfile = hydrate("gemcanary.gemfile.lock")
    @package_list, _ = GemfileParser.parse(lockfile)
    @platform = "ruby"
  end

  # TODO: test side effects!

  it "should create bundles" do
    @bm = BundleManager.new(account)

    assert_equal 0, Bundle.count
    assert_equal 0, Package.count

    pr, _ = PlatformRelease.validate(@platform)
    bundle = @bm.create(pr, {}, @package_list)
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

    bundle, error = @bm.update_packages(bundle.id, @package_list)
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
      bundle = @bm.update_packages(bundle.id, @package_list)
    end
  end

  it "should rename packages" do
    bundle = FactoryGirl.create(:bundle, 
                                :account_id => account.id, 
                                :name => "wrong")
    
    @bm = BundleManager.new(account)
    bundle, error = @bm.update_name(bundle.id, "right")
    bundle = Bundle.find(bundle.id)

    assert_equal "right", bundle.name
  end

  # TODO: lol, test with bundled packages, adoy

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
end
