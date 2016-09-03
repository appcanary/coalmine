require 'test_helper'

class UbuntuTrackerImporterTest < ActiveSupport::TestCase

  it "should do the right thing" do
    @importer = UbuntuTrackerImporter.new("test/data/ubuntu-cve-tracker")

    # we put away four advisories in our fixture
    raw_advisories = @importer.fetch_advisories
    assert_equal 4, raw_advisories.size

    # do we parse things correctly?
    all_advisories = raw_advisories.map do |ra|
      ubuntu_adv = @importer.parse(ra)
      new_attr = ubuntu_adv.to_advisory_attributes

      assert_equal "ubuntu", new_attr["package_platform"]
      assert_equal "ubuntu-tracker", new_attr["source"]

      assert new_attr["identifier"] =~ /CVE-\d\d\d\d-\d\d\d\d/
      assert ["medium", "low"].include?(new_attr["criticality"])

      # are we generating patched/affected properly?
      assert new_attr["patched"].all? { |hsh|
        ["release", "package", "version"].all? { |k|
          hsh[k].present?
        } &&
        ["released", "pending"].include?(hsh["status"])
      }

      assert new_attr["unaffected"].all? { |hsh|
        ["release", "package"].all? { |k|
          hsh[k].present?
        } &&
        ["not-affected", "DNE"].include?(hsh["status"])
      }

      assert new_attr["affected"].all? { |hsh|
        ["release", "package"].all? { |k|
          hsh[k].present?
        } &&
        ["needed", "active", "deferred", "pending", "released"].include?(hsh["status"])
      }

      ubuntu_adv
    end

    # does it dump into the db?

    @importer.process_advisories(all_advisories)
    assert_equal 4, QueuedAdvisory.from_ubuntu.count

    # is this idempotent?
    @importer.process_advisories(all_advisories)
    assert_equal 4, QueuedAdvisory.from_ubuntu.count


    new_ub_adv = @importer.parse(raw_advisories.first)
    new_ub_adv.priority = "Critical"

    @importer.process_advisories([new_ub_adv])

    assert_equal 5, QueuedAdvisory.from_ubuntu.count
  end

end
