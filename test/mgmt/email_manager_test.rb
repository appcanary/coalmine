require 'test_helper'

class EmailManagerTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false

  after :each do
    DatabaseCleaner.clean
  end

  it "should generate email messages when appropriate" do
    assert_equal 0, LogBundleVulnerability.count
    assert_equal 0, EmailMessage.count

    packages1 = FactoryGirl.create_list(:package, 10, :ruby)
    bundle1 = FactoryGirl.create(:bundle, :packages => packages1)

    vuln_pkg1 = packages1.first
    vulnerability1 = FactoryGirl.create(:vulnerability, :pkgs => [vuln_pkg1])


    packages2 = FactoryGirl.create_list(:package, 10, :ruby)

    vuln_pkg2 = packages2.first
    vulnerability2 = FactoryGirl.create(:vulnerability, :pkgs => [vuln_pkg2])


    # will have two vulns
    bundle2 = FactoryGirl.create(:bundle, :packages => packages1 + packages2)


    # user 2 has two bundles
    bundle3 = FactoryGirl.create(:bundle, :account => bundle2.account, :packages => packages1)
   
    # i could use a factory but... we have code for this
    Bundle.transaction do
      rm = ReportMaker.new(bundle1.id)
      rm.on_bundle_change

      rm = ReportMaker.new(bundle2.id)
      rm.on_bundle_change

      rm = ReportMaker.new(bundle3.id)
      rm.on_bundle_change
    end

    # user1: bundle1 (1 vuln pkg)
    # user2: bundle2 (2 vp), bundle3 (1 vp)
    assert_equal 4, LogBundleVulnerability.count

    EmailManager.queue_vuln_emails!
    
    assert_equal 2, EmailVulnerable.count, "two emails for two accounts"
    assert_equal 4, Notification.count, "one notification per LBV"

    # queue vuln emails should be idempotent
    EmailManager.queue_vuln_emails!
    
    assert_equal 2, EmailVulnerable.count, "two emails for two accounts"
    assert_equal 4, Notification.count, "one notification per LBV"

    # let's ensure the right properties got set

    email1, email2 = EmailVulnerable.order(:account_id)

    assert_equal email1.account_id, bundle1.account_id
    assert_equal email2.account_id, bundle3.account_id

    assert_equal nil, email1.sent_at
    assert_equal nil, email2.sent_at
    assert_equal 1, email1.notifications.count
    assert_equal 3, email2.notifications.count

    # okay. let's actually send these!
    EmailManager.send_vuln_emails!
    assert_equal 2, ActionMailer::Base.deliveries.size

    email1.reload
    email2.reload

    assert_not_equal nil, email1.sent_at
    assert_not_equal nil, email1.sent_at

    # this should also be idempotent
    EmailManager.send_vuln_emails!
    assert_equal 2, ActionMailer::Base.deliveries.size

    #---------- TESTING PATCH EMAILS
    
    # I could make a separate test but... I'd just be
    # recreating this state? let's 'patch' these vuln bundles

    assert_equal 0, LogBundlePatch.count
    assert_equal 0, EmailPatched.count

    # update bundle1 to remove vuln pkg
    packages1_sans_vuln = packages1[1..-1]
    BundleManager.new(bundle1.account).update_packages(bundle1.id, packages1_sans_vuln.map(&:to_pkg_builder))

    # update bundle2 to remove vuln pkgs
    packages2_sans_vuln = packages2[1..-1]
    BundleManager.new(bundle2.account).update_packages(bundle2.id, packages2_sans_vuln.map(&:to_pkg_builder))

    assert_equal 3, LogBundlePatch.count


    EmailManager.queue_patched_emails!
    assert_equal 2, EmailPatched.count
    assert_equal 3, Notification.where("log_bundle_patch_id is not null").count

    # should be idempotent
    EmailManager.queue_patched_emails!
    assert_equal 2, EmailPatched.count
    assert_equal 3, Notification.where("log_bundle_patch_id is not null").count

    # let's ensure the right properties got set
    email1, email2 = EmailPatched.order(:account_id)
    assert_equal email1.account_id, bundle1.account_id
    assert_equal email2.account_id, bundle2.account_id

    assert_equal nil, email1.sent_at
    assert_equal nil, email2.sent_at
    assert_equal 1, email1.notifications.count
    assert_equal 2, email2.notifications.count


     # okay. let's actually send these!
    EmailManager.send_patched_emails!
    # prev 2 plus another 2
    assert_equal 4, ActionMailer::Base.deliveries.size

    email1.reload
    email2.reload

    assert_not_equal nil, email1.sent_at
    assert_not_equal nil, email1.sent_at

    # this should also be idempotent
    EmailManager.send_patched_emails!
    assert_equal 4, ActionMailer::Base.deliveries.size
  end

  it "should not send emails for vulns that are unpatchable" do
    assert_equal 0, LogBundleVulnerability.count
    assert_equal 0, EmailMessage.count

    packages1 = FactoryGirl.create_list(:package, 10, :ruby)
    bundle1 = FactoryGirl.create(:bundle, :packages => packages1)

    # generate ourselves a vuln w/no patched versions
    # yes, this is very clunky

    vuln_pkg1 = packages1.first
    vuln1 = FactoryGirl.create(:vulnerability, :debian,
                           :deps => [])
    vd = FactoryGirl.create(:vulnerable_dependency,
                            :vulnerability => vuln1,
                            :platform => Platforms::Ruby,
                            :package_name => vuln_pkg1.name,
                            :patched_versions => [])

    FactoryGirl.create(:vulnerable_package,
                       :dep => vuln_pkg1, 
                       :vulnerable_dependency => vd, 
                       :vulnerability => vuln1)


    # create a second vuln cos why not

    vuln_pkg2 = packages1.second
    vuln2 = FactoryGirl.create(:vulnerability, :pkgs => [vuln_pkg2])


    Bundle.transaction do
      rm = ReportMaker.new(bundle1.id)
      rm.on_bundle_change
    end
    
    assert_equal 2, LogBundleVulnerability.count
    EmailManager.queue_vuln_emails!

    assert_equal 1, EmailVulnerable.count
    assert_equal 1, Notification.count, "one notification per LBV"

    assert_equal Notification.first.log_bundle_vulnerability_id, LogBundleVulnerability.order(:vulnerability_id).last.id
    unnotified = LogBundleVulnerability.unnotified_logs_by_account
    assert_equal 1, unnotified.count

    assert_equal LogBundleVulnerability.order(:vulnerability_id).first.id, unnotified[0][1]
  end

end
