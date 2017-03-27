require 'test_helper'

class CveImporterTest < ActiveSupport::TestCase
  it "should correctly import and parse CVEs" do
    c = CveImporter.new("test/data/importers/cve/nvdcve-2.0-Recent.xml.gz")

    assert_equal 0, Advisory.count

    c.import!

    assert_equal 475, Advisory.count

    a = Advisory.where(:identifier => "CVE-2012-5361").take

    assert_equal CveImporter::SOURCE, a.source
    assert_equal Platforms::None, a.platform
    assert_equal "high", a.criticality
    assert_equal "Libavcodec in FFmpeg before 0.11 allows remote attackers to cause a denial of service (memory corruption and application crash) or execute arbitrary code.", a.description
    # source status stores cvss data in json
    cvss = JSON.parse(a.source_status)
    assert_equal "6.8", cvss["score"]
  end
end
