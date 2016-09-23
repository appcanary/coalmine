require 'test_helper'

class TopToBottomTest < ActionDispatch::IntegrationTest
  # describe "the whole damn thing" do
  #   it "should load in advisories, spit out vulns, and flag pkgs as vulnerable" do

  #     [
  #       [RubysecImporter, "test/data/importers/rubysec"],
  #       [AlasImporter, File.join(Rails.root, "test/data/importers/alas/index.html")],
  #       [CesaImporter, "test/data/importers/cesa"],
  #       [DebianTrackerImporter, "test/data/importers/debian-tracker/sample.json"],
  #       [UbuntuTrackerImporter, "test/data/importers/ubuntu-cve-tracker"],
  #     ].each do |k, f|
  #       inst = k.new(f)
  #       # skip network calls, etc
  #       inst.stubs(:update_local_store!).returns(true)
  #       inst.import!
  #     end

  #     assert_equal 22, Advisory.count

  #     VulnerabilityImporter::IMPORTERS.each do |k|
  #       res, errors = VulnerabilityImporter.new(k::PLATFORM, k::SOURCE).import
  #     end

  #     # smoke screen tests
  #     assert_equal 22, Vulnerability.count
  #     assert_equal 338, VulnerableDependency.count

  #     # TODO finish, i kinda grew bored, whatever


  #   end
  # end
end
