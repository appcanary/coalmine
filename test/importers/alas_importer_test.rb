require 'test_helper'

class AlasImporterTest < ActiveSupport::TestCase
  it "should do the right thing" do
    @importer = AlasImporter.new(File.join(Rails.root, "test/data/alas/index.html"))

    assert_equal 0, Advisory.from_alas.count
    
    # there are four advisories in our fixture
    raw_advisories = @importer.fetch_advisories
    assert_equal 4, raw_advisories.size

    all_advisories = raw_advisories.map do |ra|
      alas_adv = @importer.parse(ra)
      new_attr = alas_adv.to_advisory_attributes

      assert_equal "amzn", new_attr["package_platform"]
      assert new_attr["identifier"] =~ /ALAS-201[4,6]-\d\d\d/

      assert ["high", "low", "critical", "medium"].include? new_attr["criticality"]

      assert new_attr["reference_ids"].all? { |cve| cve =~ /(CVE|RHSA)-\d\d\d\d-\d\d\d\d/ }
      assert_equal "alas", new_attr["source"]

      # are we generating the patched json properly?
      assert new_attr["patched"].all? { |p| p["filename"].present? }
 
      assert new_attr["constraints"].present?
      assert new_attr["constraints"].all? { |p| 
        ["package_name", "arch", "release", "patched_versions"].all? do |k|
          v = p.fetch(k) 
          !v.nil? && v != ""
        end
      }
      assert new_attr["source_text"].present?
    end

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
