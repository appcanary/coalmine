require 'test_helper'

class DailySummaryQueryTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false

  # hilariously this test is likely to flake out if it ever
  # runs at exactly midnight

  after :each do
    DatabaseCleaner.clean
  end

  let(:account) { FactoryGirl.create(:account) }
  let(:unrelated_account) { FactoryGirl.create(:account) }
  let(:packages) { FactoryGirl.create_list(:package, 20, :ubuntu) }
  let(:platform_release) { OpenStruct.new(:platform => "ubuntu", :release => "utopic") }


  setup do
    @vpkg1, @vpkg2, @vpkg3, @vpkg4, @vpkg5 = packages[0..4]

    FactoryGirl.create(:vulnerability, :pkgs => [@vpkg1])
    FactoryGirl.create(:vulnerability, :pkgs => [@vpkg1])

    FactoryGirl.create(:vulnerability, :pkgs => [@vpkg2]) 
    FactoryGirl.create(:vulnerability, :pkgs => [@vpkg3]) 

  end

  it "should report on deleted and added servers properly" do
    # ensure it's scoped to our main account
    # by creating irrelevant accounts
    unrelated_server1 = FactoryGirl.create(:agent_server, account: unrelated_account)
    unrelated_server2 = FactoryGirl.create(:agent_server, account: unrelated_account)
    unrelated_server2.destroy
    vb1 = FactoryGirl.create(:bundle, :ubuntu, account: account)
    add_to_bundle(vb1, [@vpkg1])

    vb2 = FactoryGirl.create(:bundle, :ubuntu, account: account)
    add_to_bundle(vb2, [@vpkg2])


    server1 = FactoryGirl.create(:agent_server, :ubuntu, :account => account, :bundles => [vb1])
    server2 = FactoryGirl.create(:agent_server, :ubuntu, :account => account, :bundles => [vb2])

    server3 = FactoryGirl.create(:agent_server, :account => account)
    server4 = FactoryGirl.create(:agent_server, :account => account)


    server3.destroy

    @dm = DailySummaryQuery.new(account, Date.today).create_presenter

    assert_equal 4, @dm.new_servers.count
    assert_equal 1, @dm.deleted_servers.count

    assert_equal 2, @dm.fresh_vulns.package_ct
    assert_equal 2, @dm.fresh_vulns.server_ct
    assert_equal 3, @dm.fresh_vulns.vuln_ct

    # now we delete one server.
    # this will impact the vuln counts
    server2.destroy

    @dm = DailySummaryQuery.new(account, Date.today).create_presenter

    assert_equal 4, @dm.new_servers.count
    assert_equal 2, @dm.deleted_servers.count

    # fresh vulns ignore deleted servers.
    assert_equal 1, @dm.fresh_vulns.package_ct
    assert_equal 1, @dm.fresh_vulns.server_ct
    assert_equal 2, @dm.fresh_vulns.vuln_ct

  end

  def add_to_bundle(bundle, packages)
    @bm = BundleManager.new(bundle.account)

    package_list = packages.map { |pkg| Parcel.from_package(pkg) }

    bundle, errors = @bm.update_packages(bundle.id, package_list)

    bundle
  end

end
