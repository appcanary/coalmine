require 'test_helper'

class CesaImporterTest < ActiveSupport::TestCase
  it "should do the right thing" do
    CesaImporter.any_instance.stubs(:update_local_store!).returns(true)
    @importer = CesaImporter.new("test/data/importers/cesa")

    assert_equal 0, Advisory.from_cesa.count

    # there are four packages in our fixture
    raw_advisories = @importer.fetch_advisories
    assert_equal 4, raw_advisories.size

    # check that we parse things correctly
    all_advisories = raw_advisories.map do |ra|
      cesaadv = @importer.parse(ra)
      new_attr = cesaadv.to_advisory_attributes


      assert_equal "centos", new_attr["platform"]
      assert new_attr["identifier"] =~ /CESA-2016:\d\d\d\d/

      assert Advisory.criticalities.values.include?(new_attr["criticality"])
      assert_equal "cefs", new_attr["source"]

      # are we generating the patched/affected json properly?

      assert new_attr["patched"].all? { |p| p.key?("filename") }
      assert new_attr["affected"].all? { |p| p.key?("arch") && p.key?("release") }

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

    assert_equal 4, Advisory.from_cesa.count

    # is this idempotent?
    @importer.process_advisories(all_advisories)
    assert_equal 4, Advisory.from_cesa.count

    assert_importer_mark_processed_idempotency(@importer)

    # if we change an attribute tho we should get a more
    # recent version.

    new_cesaadv = @importer.parse(raw_advisories.first)
    new_cesaadv.synopsis = "new title omg"

    @importer.process_advisories([new_cesaadv])

    assert_equal 4, Advisory.from_cesa.count
    assert_equal "new title omg", Advisory.from_cesa.order(:updated_at).last.title
  end
end
