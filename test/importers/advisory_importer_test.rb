require 'test_helper'
class AdvisoryImporterTest < ActiveSupport::TestCase
  it "should update advisories if the source material updates" do
    # it's basically an abstract class, so let's pull in a sub

    RubysecImporter.any_instance.stubs(:update_local_store!).returns(true)
    @importer = RubysecImporter.new("test/data/importers/rubysec")
    assert_equal 0, Advisory.from_rubysec.count
    @importer.import!
    assert_equal 3, Advisory.from_rubysec.count
    assert_equal 3, AdvisoryImportState.count

    # for some reason ordering is off in CI
    adv = Advisory.order(:title).first
    assert_equal false, adv.advisory_import_state.processed
    assert_equal "Denial of service or RCE from libxml2 and libxslt", adv.title

    # at some other point it gets picked up by the VulnImporter and processed
    AdvisoryImportState.update_all(:processed => true)

    # OK, so then the adv w/same identifier gets
    # edited. 
    @importer = RubysecImporter.new("test/data/importers/generic_importer")

    @importer.import!
    # nothing gets added
    assert_equal 3, Advisory.from_rubysec.count
    adv.reload

    # processed flag gets reset, so it'll be picked up 
    assert_equal false, adv.advisory_import_state.processed
    assert_equal "NEW TITLE", adv.title
    assert_equal "LOL EDITED", adv.description

    assert_equal ">= 10", adv.constraints.first["patched_versions"].first
    
  end
end
