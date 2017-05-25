require "test_helper"

class AlpineImporterTest < ActiveSupport::TestCase
  it "imports the repo correctly" do
    AlpineImporter.any_instance.stubs(:update_local_store!).returns(true)
    importer = AlpineImporter.new("test/data/importers/alpine-secdb")

    assert_equal 0, Advisory.from_alpine.count

    # 5 YAML files (repos) in our fixture
    advisory_files = importer.fetch_advisories
    assert_equal 5, advisory_files.count

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

    assert_equal ["CVE-2016-2776"], attributes["reference_ids"]
    assert_equal "alpine", attributes["source"]
    assert attributes["source_text"].present?

    assert_equal 3, attributes["related"].count
    expected = ["x86_64", "x86", "armhf"].map do |arch|
      "http://dl-cdn.alpinelinux.org/alpine/v3.3/main/#{arch}/bind-9.10.4_p3-r0.apk"
    end
    assert_equal expected.to_set, attributes["related"].to_set

    # there are 207 individual package releases in the fixtures
    all_advisories = advisory_files.map { |af| importer.parse(af) }.flatten
    assert_equal 207, all_advisories.count
    # binding.pry
    importer.process_advisories(all_advisories)

    assert_equal 207, Advisory.from_alpine.count

    assert_importer_mark_processed_idempotency(importer)

    # is this idempotent?
    importer.process_advisories(all_advisories)
    assert_equal 207, Advisory.from_alpine.count

    # tweak the first one
    adapter.cve_list << "new-ref-omg"
    importer.process_advisories([adapter])

    assert_equal 207, Advisory.from_alpine.count
    assert Advisory.from_alpine.order(:updated_at).last.reference_ids.include?("new-ref-omg")
  end
end
