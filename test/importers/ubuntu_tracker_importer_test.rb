require 'test_helper'

class UbuntuTrackerImporterTest < ActiveSupport::TestCase

  it "should do the right thing" do
    @importer = UbuntuTrackerImporter.new("test/data/importers/ubuntu-cve-tracker")
    assert_equal 0, Advisory.from_ubuntu.count

    # we put away all advisories in our fixture
    raw_advisories = @importer.fetch_advisories
    assert_equal 7, raw_advisories.size

    # parse the advisories
    all_advisories = raw_advisories.map { |ra| @importer.parse(ra)}

    # did we parse things correctly?
    all_advisories.each do |ubuntu_adv|
      new_attr = ubuntu_adv.to_advisory_attributes

      assert_equal "ubuntu", new_attr["platform"]
      assert_equal "ubuntu-cve-tracker", new_attr["source"]

      assert new_attr["identifier"] =~ /CVE-\d\d\d\d-\d\d\d\d/
      assert new_attr["reference_ids"].first =~ /CVE-\d\d\d\d-\d\d\d\d/
      assert [:medium, :low].include?(new_attr["criticality"])

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
    end

    # does it dump into the db?
    @importer.process_advisories(all_advisories)
    assert_equal 7, Advisory.from_ubuntu.count

    # Do we parse the correct reported_at date
    assert_equal Date.new(2016,01,27), Advisory.where(:identifier => "CVE-2016-0755").first.reported_at

    # is this idempotent?
    @importer.process_advisories(all_advisories)
    assert_equal 7, Advisory.from_ubuntu.count


    new_ub_adv = @importer.parse(raw_advisories.first)
    new_ub_adv.description = ["omg new description"]

    @importer.process_advisories([new_ub_adv])

    assert_equal 7, Advisory.from_ubuntu.count
    assert_equal "omg new description", Advisory.from_ubuntu.order(:updated_at).last.description
  end

end
