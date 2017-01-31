require 'test_helper'

class ServersHelperTestt < ActiveSupport::TestCase
  include ServersHelper
  test "if hide_deploy_opt behaves properly" do

    user = Struct.new(:pref_os, :pref_deploy).new

    str = hide_deploy_opt_klass(user, "chef")
    assert_equal "collapse", str

    str = hide_deploy_opt_klass(user, "chef", "foo", "bar")
    assert_equal "foo bar collapse", str

    user.pref_os = "foo"
    str = hide_deploy_opt_klass(user, "chef", "foo", "bar")
    assert_equal "foo bar collapse", str

    user.pref_os = "foo"
    user.pref_deploy = "chef"
    str = hide_deploy_opt_klass(user, "chef", "foo", "bar")
    assert_equal "foo bar", str

    user.pref_os = "fooooo"
    user.pref_deploy = "chef"
    str = hide_deploy_opt_klass(user, "chef", "foo", "bar")
    assert_equal "foo bar collapse", str

    user.pref_deploy = "chef"
    str = hide_deploy_opt_klass(user, "chef")
    assert_equal "", str
  end
end
