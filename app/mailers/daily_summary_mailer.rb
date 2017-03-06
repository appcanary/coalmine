class DailySummaryMailer < ActionMailer::Base
  default from: "Appcanary <hello@appcanary.com>"
  layout 'mailer'
  helper :application

  def daily_summary(account_id, date = "2017-01-31")
    @account = Account.find(account_id)
    date = date.to_date
    @begin_at = date
    @end_at = date + 1.day
    @vq = VulnQuery.new(@account)

    # need to get:
    # what was introduced today (packages)
    # list of affected servers 
    # high medium low vulns
    #
    #
    # so lets think this thru.
    # i want every package that became vulnerable in this
    # time period.

    # Today, January 31st 2017, you became vulnerable to 10 new vulnerabilities. They affect 5 packages present in 32 servers.
    # At the same time, 3 packages affected by 8 new vulnerabilities were patched.
    #
    # followed by a table of unpatched vulns
    # a table of packages to vulns
    # a table of patched stuff

    # basic stats
    vuln_logs = LogBundleVulnerability.select_bundles_and_vulns.in_bundles_from(account_id).that_are_unpatched.vulnerable_between(@begin_at, @end_at)
    binding.pry
    patch_logs = LogBundlePatch.select_bundles_and_vulns.in_bundles_from(account_id).that_are_not_vulnerable.patched_between(@begin_at, @end_at)

    basic_stats = vuln_logs.reduce({}) { |acc, lbv| 
      acc[:vuln] ||= {}
      acc[:pkg] ||= {}
      acc[:srv] ||= {}
      acc[:vuln][lbv.vulnerability_id] = true
      acc[:pkg][lbv.package_id] = true
      acc[:srv][lbv.agent_server_id] = true unless lbv.agent_server_id.nil?
      acc 
    }

    @vuln_ct = basic_stats[:vuln].count
    @pkg_ct = basic_stats[:pkg].count
    @srv_ct = basic_stats[:srv].count


    @vulns = Vulnerability.where("id in (?)", basic_stats[:vuln].keys)
    @pkgs = Package.where("id in (?)", basic_stats[:pkg].keys)

    @pkg_by_platform = @pkgs.group_by(&:platform)

    @new_servers = AgentServer.where(:account_id => account_id).created_on(@begin_at)
    @new_apps = Bundle.where(:account_id => account_id).app_bundles.created_on(@begin_at)
    

    # current state
    # BundledPackage.select("distinct bundled_packages.package_id").joins(:bundle).joins(:vulnerable_packages).where(:'bundles.account_id' => 22).where("vulnerable_packages.created_at >= ? and vulnerable_packages.created_at <= ?", @begin_at, @end_at)

    # LogBundleVulnerability.select_distinct_pkg.in_bundles_from(22).that_are_unpatched.vulnerable_between(22, @begin_at, @end_at)

    # LogBundleVulnerability.select("distinct(lbv.package_id)").from("log_bundle_vulnerabilities lbv").joins("inner join (select id from bundles where bundles.account_id = 22) b on b.id = lbv.bundle_id").joins("inner join vulnerable_packages vp on vp.id = lbv.vulnerable_package_id").joins("left join log_bundle_patches lbp on lbp.bundle_id = lbv.bundle_id and lbp.bundled_package_id = lbv.bundled_package_id and lbp.package_id = lbv.package_id and lbp.vulnerability_id = lbv.vulnerability_id and lbp.vulnerable_dependency_id = lbv.vulnerable_dependency_id and lbp.vulnerable_package_id = lbv.vulnerable_package_id").where("vp.created_at >= ? and vp.created_at <= ? and lbp.id is null", @begin_at, @end_at) 


    # vuln_packages = Package.joins("inner join (#{lbvs.to_sql}) lbvs on lbvs.package_id = packages.id")
    
    mail(to: "phillmv@appcanary.com", :subject => "daily summary lol") do |format|
        format.html
        format.text
    end
  end
end
