require "test_helper"

class ComposerLockParserTest < ActiveSupport::TestCase
  it "doesn't barf on drupal's compose.lock" do
    pkgs, err = ComposerLockParser.parse(hydrate("parsers", "drupal.composer.lock"))

    assert_equal 75, pkgs.count

    assert pkgs.all? { |p| p.name.present? && p.version.present? }
  end
end
