require 'test_helper'

class DailySummaryPresenterTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false

  # hilariously this test is likely to flake out if it ever
  # runs at exactly midnight

  after :each do
    DatabaseCleaner.clean
  end

  let(:account) { FactoryGirl.create(:account) }
  let(:unrelated_account) { FactoryGirl.create(:account) }

  describe "presenter" do
    it "should have the correct fields" do
      # Create our bundles and servers
      server1 = FactoryGirl.create(:agent_server, :with_bundle, account: account)
      server2 = FactoryGirl.create(:agent_server, :with_bundle, account: account)
      server3 = FactoryGirl.create(:agent_server, account: account)
      server4 = FactoryGirl.create(:agent_server, account: account)

      server3.destroy

      # ensure it's scoped to our main account
      # by creating irrelevant accounts
      unrelated_server1 = FactoryGirl.create(:agent_server, account: unrelated_account)
      unrelated_server2 = FactoryGirl.create(:agent_server, account: unrelated_account)
      unrelated_server2.destroy

      dsp = new_dsp()
      assert_equal account, dsp.account
      assert_equal Date.today, dsp.date

      # Server count dosen't show deleted
      assert_equal 3, dsp.server_ct

      # But new servers do
      assert_equal [server1, server2, server3, server4].to_set, dsp.new_servers.to_set
      assert_equal [server3], dsp.deleted_servers

      # delete a server
      server2.destroy

      dsp = new_dsp()
      assert_equal [server1, server2, server3, server4].to_set, dsp.new_servers.to_set
      assert_equal [server2, server3].to_set, dsp.deleted_servers.to_set
    end

    it "should have fresh vulns" do
      # Create some vulnerable packages
      pkg_with_2_vulns, pkg_with_1_vuln, pkg_with_1_vuln2 = FactoryGirl.create_list(:package, 3, :ubuntu)
      FactoryGirl.create(:vulnerability, pkgs: [pkg_with_2_vulns])
      FactoryGirl.create(:vulnerability, pkgs: [pkg_with_2_vulns])
      FactoryGirl.create(:vulnerability, pkgs: [pkg_with_1_vuln])
      FactoryGirl.create(:vulnerability, pkgs: [pkg_with_1_vuln2])

      server1 = FactoryGirl.create(:agent_server, :with_bundle, account: account)
      add_to_bundle(server1.bundles.first, [pkg_with_2_vulns.reload])
      server2 = FactoryGirl.create(:agent_server, :with_bundle, account: account)
      add_to_bundle(server2.bundles.first, [pkg_with_1_vuln])


      dsp = new_dsp()
      fresh_vulns = dsp.fresh_vulns

      assert_equal 2, fresh_vulns.package_ct
      assert_equal 2, fresh_vulns.server_ct
      assert_equal 3, fresh_vulns.vuln_ct

      # fresh vulns ignore deleted servers.
      server2.destroy
      fresh_vulns = new_dsp().fresh_vulns
      assert_equal 1, fresh_vulns.package_ct
      assert_equal 1, fresh_vulns.server_ct
      assert_equal 2, fresh_vulns.vuln_ct

      # Make sure we didn't mess up somewhere else
      assert_equal 0, dsp.new_vulns.vuln_ct
      assert_equal 0, dsp.patched_vulns.vuln_ct
      assert_equal 0, dsp.cantfix_vulns.vuln_ct
    end

    it "should have new vulns" do
      # vulnerability and server was created a while ago
      bundle, pkg = travel_to 10.years.ago do 
        pkg = FactoryGirl.create(:package, :ubuntu)
        FactoryGirl.create(:vulnerability, pkgs: [pkg])
        FactoryGirl.create(:vulnerability, pkgs: [pkg])
        server = FactoryGirl.create(:agent_server, :with_bundle, account: account)
        bundle = server.bundles.first
        [bundle, pkg]
      end

      # But we only became vulnerable today!
      add_to_bundle(bundle, [pkg])

      dsp = new_dsp()
      new_vulns = dsp.new_vulns
      assert_equal 1, new_vulns.package_ct
      assert_equal 2, new_vulns.vuln_ct
      assert_equal 1, new_vulns.server_ct

      # Make sure we didn't mess up somewhere else
      assert_equal 0, dsp.fresh_vulns.vuln_ct
      assert_equal 0, dsp.patched_vulns.vuln_ct
      assert_equal 0, dsp.cantfix_vulns.vuln_ct
    end

    it "should have patched vulns" do
      # You added a server and became vulnerable a while ago
      bundle = travel_to 10.years.ago do
        pkg = FactoryGirl.create(:package, :ubuntu)
        FactoryGirl.create(:vulnerability, pkgs: [pkg])
        server = FactoryGirl.create(:agent_server, :with_bundle, account: account)
        bundle = server.bundles.first
        add_to_bundle(bundle, [pkg])
        bundle
      end

      # Today you patched (by deleting the package!)
      add_to_bundle(bundle, [])

      dsp = new_dsp()
      patched_vulns = dsp.patched_vulns
      assert_equal 1, patched_vulns.package_ct
      assert_equal 1, patched_vulns.vuln_ct
      assert_equal 1, patched_vulns.server_ct

      # Make sure we didn't mess up somewhere else
      assert_equal 0, dsp.fresh_vulns.vuln_ct
      assert_equal 0, dsp.new_vulns.vuln_ct
      assert_equal 0, dsp.cantfix_vulns.vuln_ct
    end

    it "should have cantfix vulns" do
      pkg = FactoryGirl.create(:package, :ubuntu)
      FactoryGirl.create(:vulnerability, :patchless, pkgs: [pkg])
      server = FactoryGirl.create(:agent_server, :with_bundle, account: account)
      bundle = server.bundles.first
      add_to_bundle(bundle, [pkg])

      dsp = new_dsp()
      cantfix_vulns = dsp.cantfix_vulns
      assert_equal 1, cantfix_vulns.package_ct
      assert_equal 1, cantfix_vulns.vuln_ct
      assert_equal 1, cantfix_vulns.server_ct

      # Make sure we didn't mess up somewhere else
      assert_equal 0, dsp.fresh_vulns.vuln_ct
      assert_equal 0, dsp.new_vulns.vuln_ct
      assert_equal 0, dsp.patched_vulns.vuln_ct
    end

    it "should have changes" do
      bundle, pkg, pkg2, pkg3, upgraded_pkg = nil
      travel_to 10.years.ago do
        pkg = FactoryGirl.create(:package, :ubuntu, version: "11")
        pkg2 = FactoryGirl.create(:package, :ubuntu)
        pkg3 = FactoryGirl.create(:package, :ubuntu)
        upgraded_pkg = FactoryGirl.create(:package, :ubuntu, name: pkg.name, release: pkg.release, version: "12")
        server = FactoryGirl.create(:agent_server, :with_bundle, account: account)
        bundle = server.bundles.first

        # Bundle had pkg1 and pkg2
        add_to_bundle(bundle, [pkg, pkg2])

        # We need to cheat a little bit here and change valid_at of the
        # bundled_packages since Rails time travel magic can't affect postgres
        # triggers
        bundle.bundled_packages.find_each do |bp|
          # disable triggers
          ActiveRecord::Base.connection.execute("SET session_replication_role = replica;")
          bp.valid_at = Time.now
          bp.save
          ActiveRecord::Base.connection.execute("SET session_replication_role = DEFAULT;")
        end
      end

      # You upgraded pkg, removed pkg2 and added pkg3
      add_to_bundle(bundle, [pkg3, upgraded_pkg])

      dsp = new_dsp()
      changes = dsp.changes
      assert_equal 1, changes.server_ct
      assert_equal 1, changes.added_ct
      assert_equal 1, changes.upgraded_ct
      assert_equal 1, changes.removed_ct
    end


  end

  def new_dsp
    DailySummaryQuery.new(account, Date.today).create_presenter
  end

  def add_to_bundle(bundle, packages)
    @bm = BundleManager.new(bundle.account)

    package_list = packages.map { |pkg| Parcel.from_package(pkg) }

    bundle, errors = @bm.update_packages(bundle.id, package_list)

    bundle
  end

end
