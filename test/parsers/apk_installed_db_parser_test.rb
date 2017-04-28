require "test_helper"

class ApkInstalledDbParserTest < ActiveSupport::TestCase
  it "doesn't barf on a fresh 3.5 package database" do
    pkgs, err = ApkInstalledDbParser.new("3.5.1").parse(hydrate("parsers", "alpine-installed.txt"))

    assert_equal 47, pkgs.count

    assert pkgs.all? { |p| p.name.present? && p.version.present? && p.release.present? }
  end
end
