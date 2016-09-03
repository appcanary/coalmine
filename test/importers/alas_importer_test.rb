require 'test_helper'

class AlasImporterTest < ActiveSupport::TestCase
  it "should do the right thing" do
    @importer = AlasImporter.new(File.join(Rails.root, "test/data/alas/index.html"))

    assert_equal 0, Advisory.from_alas.count
    
    # there are four advisories in our fixture
    raw_advisories = @importer.fetch_advisories
    assert_equal 4, raw_advisories.size

    # check that we parse things correctly?
    alas_adv = @importer.parse(raw_advisories.first)
    new_attr = alas_adv.to_advisory_attributes

    assert_equal "amzn", new_attr["package_platform"]
    assert_equal "ALAS-2016-669", new_attr["identifier"]
    assert_equal "medium", new_attr["criticality"]
    assert_equal ["CVE-2016-3157", "CVE-2016-2383", "CVE-2016-2550", "CVE-2016-2847"], new_attr["cve_ids"]
    assert_equal "alas", new_attr["source"]

    # are we generating the patched json properly?
    assert new_attr["patched"].all? { |p| p.key?("filename") }

    # okay. does this dump into the db alright?
    all_advisories = raw_advisories.map { |ra| @importer.parse(ra) }
    @importer.process_advisories(all_advisories)

    assert_equal 4, Advisory.from_alas.count

    # is this idempotent?
    @importer.process_advisories(all_advisories)
    assert_equal 4, Advisory.from_alas.count


    # if we change an attribute tho we should get a more
    # recent version.

    new_alas_adv = @importer.parse(raw_advisories.first)
    new_alas_adv.description = "new description omg"

    @importer.process_advisories([new_alas_adv])

    assert_equal 4, Advisory.from_alas.count
    assert_equal "new description omg", Advisory.from_alas.order(:updated_at).last.description
  end
end
