require "test_helper"

class PythonSafetyDbImporterTest < ActiveSupport::TestCase
  it "imports the repo correctly" do
    PythonSafetyDbImporter.any_instance.stubs(:update_local_store!).returns(true)

    importer = PythonSafetyDbImporter.new("test/data/importers/safety-db")

    assert_equal 0, Advisory.from_python_safety_db.count

    # there's a single blob of data 
    advisory_files = importer.fetch_advisories
    assert_equal 1, advisory_files.count

    advisory_file = advisory_files.first
    adapters = importer.parse(advisory_file).sort_by { |a| a.id }

    # there are 574 advisories in the test database
    assert_equal 574, adapters.count

    adapter = adapters.first
    attributes = adapter.to_advisory_attributes

    assert_equal "pyup.io-25611", attributes["identifier"]

    assert_equal 1, attributes["affected"].count
    assert attributes["affected"].first.include?("version")
    assert attributes["affected"].first.include?("package_name")

    assert_equal 1, attributes["constraints"].count
    assert attributes["constraints"].first.include?("affected_versions")
    assert attributes["constraints"].first.include?("package_name")

    assert attributes["reference_ids"].empty?
    assert_equal "safety-db", attributes["source"]

    # take a look at a complex one
    adapter = adapters.find { |a| a.id == "pyup.io-33072" }
    attributes = adapter.to_advisory_attributes

    assert_equal 3, attributes["affected"].count
    assert attributes["affected"].all? { |a| a.include?("version") }
    assert attributes["affected"].all? { |a| a.include?("package_name") }

    assert_equal 1, attributes["constraints"].count
    assert attributes["constraints"].first.include?("affected_versions")
    assert attributes["constraints"].first.include?("package_name")

    assert_equal ["<1.4.18", ">=1.6,<1.6.10", ">=1.7,<1.7.3"].to_set,
                 attributes["affected"].map { |a| a["version"] }.to_set

    assert_equal ["<1.4.18", ">=1.6,<1.6.10", ">=1.7,<1.7.3"].to_set,
                 attributes["constraints"].first["affected_versions"].to_set

    # actually import them
    importer.process_advisories(adapters)
    assert_equal 574, Advisory.from_python_safety_db.count

    assert_importer_mark_processed_idempotency(importer)

    # is this idempotent?
    importer.process_advisories(adapters)
    assert_equal 574, Advisory.from_python_safety_db.count

    # tweak one
    adapter.advisory = "new-advisory-description-omg"
    importer.process_advisories([adapter])

    assert_equal 574, Advisory.from_python_safety_db.count
    assert_equal "new-advisory-description-omg", Advisory.from_python_safety_db.order(:updated_at).last.description
  end
end
