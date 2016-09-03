require 'test_helper'

class AdvisoryManagerTest < ActiveSupport::TestCase
=begin #TODO obviously
  setup do
    ActiveRecord::FixtureSet.create_fixtures(Rails.root.join('test', 'fixtures'), "queued_advisories")
  end

  it "should load import queued advs correctly" do 
    assert_equal 0, Advisory.count
    assert_equal 0, Vulnerability.count
    assert_equal 0, VulnerableDependency.count

    AdvisoryManager.import!
    assert_equal 10, Advisory.count
    assert_equal 10, Vulnerability.count

    rubysec_vuln_deps = VulnerableDependency.where("vulnerability_id in (select id from vulnerabilities where source = ?)", "rubysec")
    assert_equal 5, rubysec_vuln_deps.count

    ruby_adv = Advisory.where(:source => "rubysec").first

    # the chain of stuff it sets is deep and done properly
    # (rubysec vulns only have 1 vuln dep per vuln)
    assert_equal ruby_adv.patched_versions, ruby_adv.vulnerabilities.first.vulnerable_dependencies.first.patched_versions
    assert_equal ruby_adv.title, ruby_adv.vulnerabilities.first.title


    # smokescreen, seems to work!
    centos_adv = Advisory.where(:source => "cesa").first
    assert centos_adv.patched_versions.any?
    assert_not_equal centos_adv.patched_versions, centos_adv.vulnerabilities.first.vulnerable_dependencies.first.patched_versions

    assert_equal centos_adv.patched_versions.first, centos_adv.vulnerabilities.first.vulnerable_dependencies.first.patched_versions.first
    assert_equal centos_adv.title, centos_adv.vulnerabilities.first.title
  end
=end
end
