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

  it "should correctly tag 'alt' packages" do
    sample_text = "kernel-3.4.59-8.el6.centos.alt.src"

    pkgs, err = RPM::Parser.parse(sample_text)

    kernel = pkgs.first

    assert_equal "kernel^alt", kernel.name
    assert_equal "kernel-3.4.59-8.el6.centos.alt.src", kernel.version
    assert_equal "src", kernel.arch
  end
end

