require 'test_helper'
class NevraTest < ActiveSupport::TestCase
  # TODO: LOL TEST WITH EPOCHS??
  it "should output valid EVRA strings" do
    constraints = ["wpa_supplicant-2.0-17.el7_1.src.rpm", "wpa_supplicant-2.0-17.el7_1.x86_64.rpm"]

    filename = "wpa_supplicant-2.0-17.el7_1.x86_64"
    nevra1 = RPM::Nevra.new(filename)

    saved_evra = nevra1.to_evra

    package = OpenStruct.new(:name => "wpa_supplicant", :version => saved_evra)
    nevra2 = RPM::Nevra.from_package(package)

    assert_equal nevra1.to_h, nevra2.to_h
  end

  it "should compare different versions properly" do
    f1 = "openssh-server-6.6.1p1-22.el7.x86_64"
    f2 = "openssh-server-6.7.1p1-22.el7.x86_64"

    n1 = RPM::Nevra.new(f1)
    n2 = RPM::Nevra.new(f2) 

    assert (n1 <=> n2) < 0

    # ignores name component
    f1 = "openssh-server-6.6.1p1-22.el7.x86_64"
    f2 = "openssh-6.7.1p1-22.el7.x86_64"

    n1 = RPM::Nevra.new(f1)
    n2 = RPM::Nevra.new(f2) 

    assert (n1 <=> n2) < 0


    # it checks version before it checks release
    f1 = "openssh-server-6.6.1p1-22.el7.x86_64"
    f2 = "openssh-server-6.7.1p1-22.el6.x86_64"

    n1 = RPM::Nevra.new(f1)
    n2 = RPM::Nevra.new(f2) 

    assert (n1 <=> n2) < 0

    # but if version is the same, then rel matters
    f1 = "openssh-server-6.6.1p1-22.el7.x86_64"
    f2 = "openssh-server-6.6.1p1-22.el6.x86_64"

    n1 = RPM::Nevra.new(f1)
    n2 = RPM::Nevra.new(f2) 

    assert (n1 <=> n2) > 0
  end
end
