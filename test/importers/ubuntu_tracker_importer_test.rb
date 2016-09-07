require 'test_helper'

class UbuntuTrackerImporterTest < ActiveSupport::TestCase

  it "should do the right thing" do
    @importer = UbuntuTrackerImporter.new("test/data/ubuntu-cve-tracker")
    assert_equal 0, Advisory.from_ubuntu.count

    # we put away four advisories in our fixture
    raw_advisories = @importer.fetch_advisories
    assert_equal 6, raw_advisories.size

    # do we parse things correctly?
    all_advisories = raw_advisories.map do |ra|
      ubuntu_adv = @importer.parse(ra)
      new_attr = ubuntu_adv.to_advisory_attributes

      assert_equal "ubuntu", new_attr["package_platform"]
      assert_equal "ubuntu-cve-tracker", new_attr["source"]

      assert new_attr["identifier"] =~ /CVE-\d\d\d\d-\d\d\d\d/
      assert new_attr["reference_ids"].first =~ /CVE-\d\d\d\d-\d\d\d\d/
      assert ["medium", "low"].include?(new_attr["criticality"])

      # are we generating patched/affected properly?
      assert new_attr["patched"].all? { |hsh|
        ["release", "package_name", "version"].all? { |k|
          v = hsh.fetch(k)

          # sometimes versions can be nil
          if k == "version"
            v.nil? || v != ""
          else
            v.present?
          end
        } &&
        ["released", "pending"].include?(hsh["status"])
      }

      assert new_attr["unaffected"].all? { |hsh|
        ["release", "package_name"].all? { |k|
          hsh[k].present?
        } &&
        ["not-affected", "DNE"].include?(hsh["status"])
      }

      assert new_attr["affected"].all? { |hsh|
        ["release", "package_name"].all? { |k|
          hsh[k].present?
        } &&
        ["needed", "active", "deferred", "pending", "released"].include?(hsh["status"])
      }

      assert new_attr["constraints"].present?
      assert new_attr["constraints"].all? { |p| 
        # must have
        must = ["package_name", "release"].all? do |k|
          v = p.fetch(k)
          v.present?
        end

        # if present should not be empty
        should = ["patched_versions",
                  "end_of_life",
                  "pending"].all? do |k|
          if v = p[k] 
            v.present?
          else
            true
          end
        end

        must && should
      }

      assert new_attr["source_text"].present?

      ubuntu_adv
    end

    # does it dump into the db?

    @importer.process_advisories(all_advisories)
    assert_equal 6, Advisory.from_ubuntu.count

    # is this idempotent?
    @importer.process_advisories(all_advisories)
    assert_equal 6, Advisory.from_ubuntu.count


    new_ub_adv = @importer.parse(raw_advisories.first)
    new_ub_adv.description = ["omg new description"]

    @importer.process_advisories([new_ub_adv])

    assert_equal 6, Advisory.from_ubuntu.count
    assert_equal "omg new description", Advisory.from_ubuntu.order(:updated_at).last.description
  end

end
