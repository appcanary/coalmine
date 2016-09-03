require 'test_helper'

class RubysecImporterTest < ActiveSupport::TestCase
  it "should do the right thing" do
    @importer = RubysecImporter.new("test/data/rubysec")

    assert_equal 0, Advisory.from_rubysec.count
    # there are three gems in our fixtures

    raw_advisories = @importer.fetch_advisories
    assert_equal 3, raw_advisories.size

    # how well is parsing working?
    rbadv = @importer.parse(raw_advisories.first)
    new_attr = rbadv.to_advisory_attributes

    assert_equal "activerecord/CVE-2016-6317.yml", new_attr["identifier"]

    assert_equal "ruby", new_attr["package_platform"]
    assert_equal ["CVE-2016-6317"], new_attr["cve_ids"]

    # are we generating the pathed/unaffected json objects properly?
    assert new_attr["patched"].all? { |p| p.key?("constraint") }
    assert new_attr["unaffected"].all? { |p| p.key?("constraint") }

    assert_equal "rubysec", new_attr["source"]
    assert new_attr["source_text"].present?

    # okay. does this dump into the db alright?

    all_advisories = raw_advisories.map { |ra| @importer.parse(ra) }
    @importer.process_advisories(all_advisories)

    assert_equal 3, Advisory.from_rubysec.count

    # is this idempotent?
    @importer.process_advisories(all_advisories)
    assert_equal 3, Advisory.from_rubysec.count

    # if we change an attribute tho we should get a more
    # recent version.

    new_rbadv = @importer.parse(raw_advisories.first)
    new_rbadv.title = "new title omg"

    @importer.process_advisories([new_rbadv])

    assert_equal 3, Advisory.from_rubysec.count
    assert_equal "new title omg", Advisory.from_rubysec.order(:updated_at).last.title
  end
end
