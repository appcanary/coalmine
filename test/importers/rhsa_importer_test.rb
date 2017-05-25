require "test_helper"

class RHSAImporterTest < ActiveSupport::TestCase
  it "correctly imports and parses RHSA data" do
    VCR.use_cassette("rhsa_importer") do
      from_date = DateTime.parse("2017-04-14T00:00:00Z")
      importer = RHSAImporter.new(from_date)

      assert_equal 0, Advisory.from_rhsa.count

      advisories = importer.fetch_advisories
      assert_equal 29, advisories.size

      # RHSA-2017:1118
      advisory = advisories.first
      assert_equal "RHSA-2017:1118", advisory.css("RHSA").text

      adapter = importer.parse(advisory)
      attributes = adapter.to_advisory_attributes

      assert_equal "RHSA-2017:1118", attributes["identifier"]

      # 1 RHSA_ID and 6 CVEs
      assert_equal 7, attributes["reference_ids"].count

      assert_equal ["RHSA-2017:1118",
                    "CVE-2017-3509",
                    "CVE-2017-3511",
                    "CVE-2017-3526",
                    "CVE-2017-3533",
                    "CVE-2017-3539",
                    "CVE-2017-3544"].to_set,
                   attributes["reference_ids"].to_set

      assert_equal "rhsa", attributes["source"]
      assert attributes["source_text"].present?

      all_advisories = advisories.map { |a| importer.parse(a) }
      assert_equal 29, all_advisories.count

      assert_equal 0, Advisory.from_rhsa.count
      importer.process_advisories(all_advisories)

      # Although there are 29 entries in the index, there are only 24 unique
      # ones (yep, duplicate data right next to itself in the index
      # feed ¯\_(ツ)_/¯)
      assert_equal 24, Advisory.from_rhsa.count

      assert_importer_mark_processed_idempotency(importer)

      importer.process_advisories(all_advisories)
      assert_equal 24, Advisory.from_rhsa.count

      adapter = importer.parse(advisory)
      adapter.title = "new title omg"

      importer.process_advisories([adapter])

      assert_equal 24, Advisory.from_rhsa.count
      assert_equal "new title omg", Advisory.from_rhsa.order(:updated_at).last.title
    end
  end
end
