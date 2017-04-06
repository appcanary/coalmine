require "test_helper"

class FriendsOfPHPImporterTest < ActiveSupport::TestCase
  it "imports the repo correctly" do
    FriendsOfPHPImporter.any_instance.stubs(:update_local_store!).returns(true)
    @importer = FriendsOfPHPImporter.new("test/data/importers/friendsofphp")

    assert_equal 0, Advisory.from_friends_of_php.count

    # there are 51 packages in our fixtures
    advisory_files = @importer.fetch_advisories.sort
    assert_equal 51, advisory_files.size

    # aws/aws-sdk-php/2015-08-31.yaml - contains one branch
    advisory_file = advisory_files.first
    assert advisory_file.end_with?("aws/aws-sdk-php/2015-08-31.yaml")

    adapter = @importer.parse(advisory_file)
    attributes = adapter.to_advisory_attributes

    assert_equal "aws/aws-sdk-php/2015-08-31.yaml", attributes["identifier"]

    assert_equal 1, attributes["affected"].count
    assert attributes["affected"].all? { |vc| vc.key?("version") }
    assert attributes["affected"].all? { |vc| vc.key?("package_name") }

    assert_equal ["CVE-2015-5723"], attributes["reference_ids"]

    assert_equal "friendsofphp", attributes["source"]
    assert attributes["source_text"].present?

    assert attributes["constraints"].present?
    assert_equal 1, attributes["constraints"].count

    constraint = attributes["constraints"].first
    assert "aws/aws-sdk-php", constraint["package_name"]
    assert_equal ['>=3.0.0,<3.2.1'], constraint["affected_versions"]

    all_advisories = advisory_files.map { |af| @importer.parse(af) }
    @importer.process_advisories(all_advisories)

    assert_equal 51, Advisory.from_friends_of_php.count

    assert_importer_mark_processed_idempotency(@importer)

    # is this idempotent?
    @importer.process_advisories(all_advisories)
    assert_equal 51, Advisory.from_friends_of_php.count

    adapter = @importer.parse(advisory_file)
    adapter.title = "new title omg"

    @importer.process_advisories([adapter])

    assert_equal 51, Advisory.from_friends_of_php.count
    assert_equal "new title omg", Advisory.from_friends_of_php.order(:updated_at).last.title
  end

  test "correctly imports multiple constraints" do
    FriendsOfPHPImporter.any_instance.stubs(:update_local_store!).returns(true)
    @importer = FriendsOfPHPImporter.new("test/data/importers/friendsofphp")
    assert_equal 0, Advisory.from_friends_of_php.count

    advisory_files = @importer.fetch_advisories.sort

    # laravel/socialite/2015-08-03.yaml - contains 2 branches
    advisory_file = advisory_files.last
    assert advisory_file.end_with?("laravel/socialite/2015-08-03.yaml")

    adapter = @importer.parse(advisory_file)
    attributes = adapter.to_advisory_attributes

    assert_equal 2, attributes["affected"].count
    assert attributes["affected"].all? { |vc| vc.key?("version") }
    assert attributes["affected"].all? { |vc| vc.key?("package_name") }

    assert attributes["constraints"].present?
    assert_equal 2, attributes["constraints"].count

    constraint1 = attributes["constraints"].first
    constraint2 = attributes["constraints"].last
    assert_equal "laravel/socialite", constraint1["package_name"]
    assert_equal "laravel/socialite", constraint2["package_name"]
    assert_equal ['>=1.0.0,<1.0.99'], constraint1["affected_versions"]
    assert_equal ['>=2.0.0,<2.0.10'], constraint2["affected_versions"]
  end
end
