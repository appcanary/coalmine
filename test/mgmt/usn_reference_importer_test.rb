require 'test_helper'

class UsnReferenceImporterTest < ActiveSupport::TestCase
  let(:usn_adv) {
    FactoryGirl.create(:advisory,
                       :source => "usn",
                       :platform => Platforms::Ubuntu,
                       :identifier => "USN-999-9",
                       :reference_ids => ["CVE-2017-0001"])
  }

  let(:related_ubuntu_adv) {
    FactoryGirl.create(:advisory,
                       :source => "ubuntu-cve-tracker",
                       :platform => Platforms::Ubuntu,
                       :identifier => "CVE-2017-0001",
                       :reference_ids => ["CVE-2017-0001"])
  }

  let(:unrelated_ubuntu_adv) {
    FactoryGirl.create(:advisory,
                       :source => "ubuntu-cve-tracker",
                       :platform => Platforms::Ubuntu,
                       :identifier => "CVE-2017-0002",
                       :reference_ids => ["CVE-2017-0002"])
  }

  it "adds USN references to Ubuntu CVEs" do
    # run the importer
    assert_equal "CVE-2017-0001", related_ubuntu_adv.identifier
    assert_equal ["CVE-2017-0001"], related_ubuntu_adv.reference_ids
    assert_equal "CVE-2017-0002", unrelated_ubuntu_adv.identifier
    assert_equal ["CVE-2017-0002"], unrelated_ubuntu_adv.reference_ids

    assert_equal 0, usn_adv.advisory_import_state.processed_count

    UsnReferenceImporter.import_references

    usn_adv.reload
    assert_equal 1, usn_adv.advisory_import_state.processed_count

    related_ubuntu_adv.reload
    unrelated_ubuntu_adv.reload

    assert_equal "CVE-2017-0001", related_ubuntu_adv.identifier
    assert_equal ["CVE-2017-0001", "USN-999-9"], related_ubuntu_adv.reference_ids
    assert_equal "CVE-2017-0002", unrelated_ubuntu_adv.identifier
    assert_equal ["CVE-2017-0002"], unrelated_ubuntu_adv.reference_ids
  end

  it "no longer attempts to process a fully processed USN" do
    # ensure these are loaded
    assert_equal "CVE-2017-0001", related_ubuntu_adv.identifier
    assert_equal "CVE-2017-0002", unrelated_ubuntu_adv.identifier
    assert_equal 0, usn_adv.advisory_import_state.processed_count

    UsnReferenceImporter.import_references

    usn_adv.reload
    assert_equal 1, usn_adv.advisory_import_state.processed_count

    assert Advisory.from_usn.unprocessed_or_incomplete.empty?
  end

  it "does attempt to process an incompletely processed advisory" do
    # ensure these are loaded
    assert_equal "CVE-2017-0001", related_ubuntu_adv.identifier
    assert_equal "CVE-2017-0002", unrelated_ubuntu_adv.identifier

    # we need a dangling reference
    usn_adv.reference_ids << "CVE-2017-0003"
    usn_adv.save!

    UsnReferenceImporter.import_references

    usn_adv.reload
    assert_equal 1, usn_adv.advisory_import_state.processed_count

    assert_equal 1, Advisory.from_usn.unprocessed_or_incomplete.count

    # verify that we haven't added an extra reference to the first one
    related_ubuntu_adv.reload
    assert_equal 2, related_ubuntu_adv.reference_ids.count
    assert_equal usn_adv.identifier, related_ubuntu_adv.reference_ids.last
  end
end
