require 'test_helper'

class GemfileParserTest < ActiveSupport::TestCase
  it "should do bare minimum smoke screen" do
    pkgs, err = GemfileParser.parse(hydrate("parsers", "420rails.gemfile.lock"))

    assert_equal 146, pkgs.count

    assert pkgs.all? { |p| p.name.present? && p.version.present? }
  end
end
