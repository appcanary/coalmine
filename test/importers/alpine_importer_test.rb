require "test_helper"

class AlpineImporterTest < ActiveSupport::TestCase
  it "imports the repo correctly" do
    AlpineImporter.any_instance.stubs(:update_local_store!).returns(true)
    importer = AlpineImporter.new("test/data/importers/alpine-secdb")

    assert_equal 0, Advisory.from_alpine.count

    # 5 YAML files (repos) in our fixture
    advisory_files = importer.fetch_advisories
    assert_equal 7, advisory_files.count

    advisory_file = advisory_files.first
    assert advisory_file.end_with?("v3.3/main.yaml")

    adapters = importer.parse(advisory_file)
    assert_equal 32, adapters.count

    adapter = adapters.first
    attributes = adapter.to_advisory_attributes

    assert_equal "v3.3/main/bind-9.10.4_p3-r0", attributes["identifier"]

    assert_equal 1, attributes["patched"].count
    assert attributes["patched"].all? { |vc| vc.key?("version") }
    assert attributes["patched"].all? { |vc| vc.key?("package_name") }

    assert attributes["constraints"].all? { |vc| vc.key?("patched_versions") }
    assert attributes["constraints"].all? { |vc| vc.key?("package_name") }
    assert attributes["constraints"].all? { |vc| vc.key?("release") }

    assert_equal ["CVE-2016-2776"], attributes["reference_ids"]
    assert_equal "alpine", attributes["source"]
    assert attributes["source_text"].present?

    # Make sure we parse Xen advisories reference IDs correctly (they include CVE and XEN)
    advisory_file = advisory_files.sort.last
    assert advisory_file.end_with?("v3.6/main.yaml")
    adapters = importer.parse(advisory_file)
    assert_equal 79, adapters.count
    xen_adv = adapters.select {|a| a.package_name == "xen"}.first.to_advisory_attributes
    assert_equal ["CVE-2016-6258", "XSA-182", "CVE-2016-6259", "XSA-183", "CVE-2016-5403", "XSA-184"], xen_adv["reference_ids"]

    # Make sure we parse advisories that look like "CVE-2017-7186.patch" correctly
    dotpatch_adv = adapters.select { |a| a.package_name == "pcre" }.first.to_advisory_attributes
    assert_equal ["CVE-2017-7186.patch"], dotpatch_adv["source_text"]["pkg"]["secfixes"]["8.40-r2"]
    assert_equal ["CVE-2017-7186"], dotpatch_adv["reference_ids"]

    # Make sure we parse advisories that look like "CVE-2017-2616 (+ regression fix)" correctly
    advisory_file = advisory_files.sort[-2]
    assert advisory_file.end_with?("v3.6/community.yaml")
    adapters = importer.parse(advisory_file)
    reg_adv = adapters.select { |a| a.package_name == "shadow"}.first.to_advisory_attributes
    assert_equal ["CVE-2016-6252", "CVE-2017-2616 (+ regression fix)"], reg_adv["source_text"]["pkg"]["secfixes"]["4.2.1-r7"]
    assert_equal ["CVE-2016-6252", "CVE-2017-2616"], reg_adv["reference_ids"]

    # there are 347 individual package releases in the fixtures
    all_advisories = advisory_files.map { |af| importer.parse(af) }.flatten
    assert_equal 347, all_advisories.count

    importer.process_advisories(all_advisories)

    assert_equal 347, Advisory.from_alpine.count

    assert_importer_mark_processed_idempotency(importer)

    # is this idempotent?
    importer.process_advisories(all_advisories)
    assert_equal 347, Advisory.from_alpine.count

    # tweak the first one
    adapter.ref_list << "new-ref-omg"
    importer.process_advisories([adapter])

    assert_equal 347, Advisory.from_alpine.count
    assert Advisory.from_alpine.order(:updated_at).last.reference_ids.include?("new-ref-omg")
  end
end
