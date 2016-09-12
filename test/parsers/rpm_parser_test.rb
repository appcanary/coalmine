require 'test_helper'

class RpmParserTest < ActiveSupport::TestCase
  it "should do bare minimum smoke screen" do
    pkgs, err = RPM::Parser.parse(hydrate("parsers", "centos-7-rpmqa.txt"))

    assert_equal 356, pkgs.count

    assert pkgs.all? { |p| 
      p.name.present? && p.version.present? &&
        p.arch.present? }
  end

  it "should split some stuff out appropriately" do
    sample_text = "openssh-server-6.6.1p1-22.el7.x86_64"

    pkgs, err = RPM::Parser.parse(sample_text)

    openssh = pkgs.first

    assert_equal "openssh-server", openssh.name
    assert_equal "openssh-server-6.6.1p1-22.el7.x86_64", openssh.version
    assert_equal "x86_64", openssh.arch
  end
end

