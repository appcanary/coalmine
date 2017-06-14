require "test_helper"

class ApkInstalledDbParserTest < ActiveSupport::TestCase
  it "doesn't barf on a fresh 3.5 package database" do
    pkgs, err = ApkInstalledDbParser.parse(hydrate("parsers", "alpine-installed-3.5.2.txt"))

    assert_equal 47, pkgs.count

    assert pkgs.all? { |p| p.name.present? && p.version.present? }
  end
end
