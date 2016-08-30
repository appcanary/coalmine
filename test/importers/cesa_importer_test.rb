require 'test_helper'

class CesaImporterTest < ActiveSupport::TestCase
  it "should do the right thing" do
    @importer = CesaImporter.new("test/data/cesa")

    assert_equal 0, QueuedAdvisory.from_cesa.count

    # there are four packages in our fixture
    raw_advisories = @importer.fetch_advisories
    assert_equal 4, raw_advisories.size

    # check that we parse things correctly
    cesaadv = @importer.parse(raw_advisories.first)
    new_attr = cesaadv.to_advisory_attributes

    
    assert_equal "centos", new_attr["package_platform"]
    assert_equal "CESA-2016:0043", new_attr["identifier"]
    assert_equal "medium", new_attr["criticality"]
    assert_equal "cesa", new_attr["source"]

    # are we generating the patched/affected json properly?
    
    assert new_attr["patched"].all? { |p| p.key?("filename") }
    assert new_attr["affected"].all? { |p| p.key?("arch") && p.key?("release") }


    # okay. does this dump into the db alright?

    all_advisories = raw_advisories.map { |ra| @importer.parse(ra) }
    @importer.process_advisories(all_advisories)

    assert_equal 4, QueuedAdvisory.from_cesa.count

    # is this idempotent?
    @importer.process_advisories(all_advisories)
    assert_equal 4, QueuedAdvisory.from_cesa.count


     # if we change an attribute tho we should get a more
    # recent version.

    new_cesaadv = @importer.parse(raw_advisories.first)
    new_cesaadv.synopsis = "new title omg"

    @importer.process_advisories([new_cesaadv])

    assert_equal 5, QueuedAdvisory.from_cesa.count
  end
end
