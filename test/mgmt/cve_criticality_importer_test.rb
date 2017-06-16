require 'test_helper'

class CveCriticalityImporterTest < ActiveSupport::TestCase
  let(:cve_adv) {
    FactoryGirl.create(:advisory,
                       :source => "cve",
                       :platform => Platforms::Ubuntu,
                       :identifier => "CVE-2017-0001",
                       :cvss => 9.0)
  }

  let(:related_ubuntu_vuln) {
    FactoryGirl.create(:vulnerability,
                       :platform => Platforms::Ubuntu,
                       :title => "CVE-2017-0001",
                       :reference_ids => ["CVE-2017-0001"],
                       :criticality => Advisory.criticalities["low"])
  }

  let(:unrelated_ubuntu_vuln) {
    FactoryGirl.create(:vulnerability,
                       :platform => Platforms::Ubuntu,
                       :title => "CVE-2017-0002",
                       :reference_ids => ["CVE-2017-0002"],
                       :criticality => Advisory.criticalities["medium"])
  }




  it "adds criticalities to vulns" do
    cve_adv.reload
    assert_equal "low", related_ubuntu_vuln.criticality
    assert_equal nil, related_ubuntu_vuln.cvss
    assert_equal "medium", unrelated_ubuntu_vuln.criticality
    assert_equal nil, unrelated_ubuntu_vuln.cvss

    # It touches the correct ones
    CveCriticalityImporter.import_criticalities
    assert_equal "critical", related_ubuntu_vuln.reload.criticality
    assert_equal 9.0, related_ubuntu_vuln.reload.cvss

    # It doesnt touch the other ones
    assert_equal "medium", unrelated_ubuntu_vuln.reload.criticality
    assert_equal nil, unrelated_ubuntu_vuln.reload.cvss
  end

end
