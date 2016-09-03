require 'test_helper'

class DebianTrackerImporterTest < ActiveSupport::TestCase
  it "should do the right thing" do
    @importer = DebianTrackerImporter.new("test/data/debian-tracker/sample.json")

    assert_equal 0, Advisory.from_debian.count

    raw_advisories = @importer.fetch_advisories
    assert_equal 4, raw_advisories.size

    all_advisories = raw_advisories.map do |ra|
      adv = @importer.parse(ra)
      nattr = adv.to_advisory_attributes

      assert_equal "debian", nattr["package_platform"]
      assert_equal "debian-tracker", nattr["source"]

      assert nattr["identifier"] =~ /CVE-\d\d\d\d-\d\d\d\d-[a-z]+/
      assert nattr["cve_ids"].all? { |cve| cve =~ /CVE-\d\d\d\d-\d\d\d\d/ }

      assert ["critical", "high", "medium", "low", "negligible", "unknown"].include?(nattr["criticality"])


      assert nattr["affected"].all? { |h|
        h["release"].present? &&
          h["package"] == adv.package_name
      }

      assert nattr["patched"].all? { |h|
        h["release"].present? &&
          h["package"] == adv.package_name &&
          h["version"].present?
      }


      assert nattr["source_text"].present?
      adv
    end

    # does it dump into the db?

    @importer.process_advisories(all_advisories)
    assert_equal 4, Advisory.from_debian.count

    # is this idempotent?
    @importer.process_advisories(all_advisories)
    assert_equal 4, Advisory.from_debian.count

    new_db_adv = @importer.parse(raw_advisories.first)
    new_db_adv.description = "omg new description"

    @importer.process_advisories([new_db_adv])

    assert_equal 4, Advisory.from_debian.count
    assert_equal "omg new description", Advisory.from_debian.order(:updated_at).last.description
  end
end
