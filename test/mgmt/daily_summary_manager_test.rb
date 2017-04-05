require 'test_helper'

class DailySummaryManagerTest < ActiveSupport::TestCase

  before :all do
    $rollout.activate(:all_staging_notifications)
  end

  before :each do
    ActionMailer::Base.deliveries.clear
  end


  it "should idempotently only send email to active users" do
    user1 = FactoryGirl.create(:user, pref_email_frequency: PrefOpt::EMAIL_FREQ_DAILY)
    user2 = FactoryGirl.create(:user, pref_email_frequency: PrefOpt::EMAIL_FREQ_BOTH)
    account = user1.account
    inactive_account = user2.account

    bundle1 = FactoryGirl.create(:bundle_with_packages, account: account)


    assert_equal 0, EmailDailySummary.count
    DailySummaryManager.send_todays_summary!

    # only account1 gets an email: only active account,
    # whose preferences want emails

    assert_equal 1, EmailDailySummary.count
    assert_equal account.id, EmailDailySummary.first.account_id

    # if I re-run the summary, no new emails are sent,
    # because it's checked idempotently
    
    DailySummaryManager.send_todays_summary!
    assert_equal 1, EmailDailySummary.count


    # but let's say the inactive account adds a server
    FactoryGirl.create(:agent_server, :with_heartbeat, :account => inactive_account)

    # now another email will get sent out

    DailySummaryManager.send_todays_summary!
    assert_equal 2, EmailDailySummary.count

    assert_equal inactive_account.id, EmailDailySummary.last.account_id


    # ensures these actually got queued
    assert_equal 2, ActionMailer::Base.deliveries.size
  end

  it "should not send email to ppl who don't want it" do
    no_ds_user = FactoryGirl.create(:user, :pref_email_frequency => PrefOpt::EMAIL_FREQ_NEVER)
    no_ds_account = no_ds_user.account

    bundle1 = FactoryGirl.create(:bundle_with_packages, account: no_ds_account)


    assert_equal 0, EmailDailySummary.count
    DailySummaryManager.send_todays_summary!
    assert_equal 0, EmailDailySummary.count


    # but then let's say they change their email prefs
    no_ds_user.pref_email_frequency = PrefOpt::EMAIL_FREQ_BOTH
    no_ds_user.save!

    # now another email will get sent out

    DailySummaryManager.send_todays_summary!
    assert_equal 1, EmailDailySummary.count

    assert_equal no_ds_account.id, EmailDailySummary.last.account_id

    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  it "should only send daily summaries when vulnerabilities to people who want that" do
    ds_only_vuln_user = FactoryGirl.create(:user, :pref_email_frequency => PrefOpt::EMAIL_FREQ_DAILY_WHEN_VULN)
    ds_only_vuln_account = ds_only_vuln_user.account
    bundle = FactoryGirl.create(:bundle_with_packages, account: ds_only_vuln_account)

    # No emails cuz no vulns
    assert_equal 0, EmailDailySummary.count
    DailySummaryManager.send_todays_summary!
    assert_equal 0, EmailDailySummary.count


    # Now we have a vulnerability that affects user2
    vuln = FactoryGirl.create(:vulnerability, pkgs: [bundle.packages.first])
    ReportMaker.new.on_vulnerability_change(vuln.id)

    # normally the daily summar is sent for Date.yesterday but we created the vuln now so send the daily summary for this very moment
    DailySummaryManager.send_todays_summary!(Date.today)
    assert_equal 1, EmailDailySummary.count

    assert_equal ds_only_vuln_account.id, EmailDailySummary.last.account_id

    assert_equal 1, ActionMailer::Base.deliveries.size

    # User should also get an email when they create a server
    ds_only_vuln_user2 = FactoryGirl.create(:user, :pref_email_frequency => PrefOpt::EMAIL_FREQ_DAILY_WHEN_VULN)
    ds_only_vuln_account2 = ds_only_vuln_user2.account
    server = FactoryGirl.create(:agent_server, :with_heartbeat, account: ds_only_vuln_account2)

    DailySummaryManager.send_todays_summary!(Date.today)
    assert_equal 2, EmailDailySummary.count

    assert_equal [ds_only_vuln_account.id, ds_only_vuln_account2.id].to_set, EmailDailySummary.pluck(:account_id).to_set

    assert_equal 2, ActionMailer::Base.deliveries.size


  end
end
