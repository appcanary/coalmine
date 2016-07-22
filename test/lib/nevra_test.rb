require 'test_helper'
class NevraTest < ActiveSupport::TestCase
  # TODO: LOL TEST WITH EPOCHS??
  it "should output valid EVRA strings" do
    constraints = ["wpa_supplicant-2.0-17.el7_1.src.rpm", "wpa_supplicant-2.0-17.el7_1.x86_64.rpm"]

    filename = "wpa_supplicant-2.0-17.el7_1.x86_64"
    nevra1 = RPM::Nevra.new(filename)
    saved_evra = nevra1.to_evra

    nevra2 = RPM::Nevra.from_evra(saved_evra)
    assert_equal nevra1.to_h.except(:name), nevra2.to_h.except(:name)
  end
end
