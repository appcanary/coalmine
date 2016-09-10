require 'test_helper'

class DpkgParserTest < ActiveSupport::TestCase
  test "whether it loads things properly" do
    file = File.read(File.join(Rails.root, "test/data/parsers/debian-jessie-dpkg-status.txt"))

    parcels, error = DpkgStatusParser.parse(file)
    assert_equal 512, parcels.count

    # smokescreen: none of these values are set
    # to nil, and they were scooped out properly
    assert_nothing_raised do 
      parcels.each do |p|
        assert p.name.present?
        Dpkg::Evr.from_s(p.version)

        if p.source_version
          Dpkg::Evr.from_s(p.source_version)
        end
      end
    end


    file2 = File.read(File.join(Rails.root, "test/data/parsers/ubuntu-trusty-dpkg-status.txt"))

    parcels, error = DpkgStatusParser.parse(file2)
    assert_equal 660, parcels.count

    # smokescreen: none of these values are set
    # to nil, and they were scooped out properly
    assert_nothing_raised do 
      parcels.each do |p|
        assert p.name.present?
        Dpkg::Evr.from_s(p.version)

        if p.source_version
          Dpkg::Evr.from_s(p.source_version)
        end
      end
    end
  end
end
