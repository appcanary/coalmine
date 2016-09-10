require 'test_helper'

class RpmParserTest < ActiveSupport::TestCase
  it "should do bare minimum smoke screen" do
    pkgs, err = RPM::Parser.parse(hydrate("parsers", "centos-7-rpmqa.txt"))

    assert_equal 356, pkgs.count

    assert pkgs.all? { |p| 
      p.name.present? && p.version.present? &&
        p.arch.present? }
  end
end

