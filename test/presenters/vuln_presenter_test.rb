require 'test_helper'

class VulnPresenterTest < ActiveSupport::TestCase
  test "whether get_host_without_www is well behaved" do
    # doesn't matter what we pass in
    vp = VulnPresenter.new([])

    assert_equal "example.com", vp.get_host_without_www("http://example.com")
    assert_equal "example.com", vp.get_host_without_www("https://example.com")
    assert_equal "example.com", vp.get_host_without_www("http://example.com sometimes they leave comments")

    assert_nil vp.get_host_without_www("http://example.com/foo{}$$ test")
  end
end

