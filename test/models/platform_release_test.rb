require 'test_helper'

class PackageReleaseTest < ActiveSupport::TestCase
  it "should work for ruby" do
    pr, err = PlatformRelease.validate(Platforms::Ruby)
    assert_nil err

    assert_equal "ruby", pr.platform
    assert_nil pr.release


    # When we don't specify a release, we accept anything as well as nil
    pr, err = PlatformRelease.validate(Platforms::Ruby, "lol")
    assert_nil err

    assert_equal "lol", pr.release

    pr, err = PlatformRelease.validate("RUBY")
    assert_nil pr
  end

  it "should work for centos" do
    pr, err = PlatformRelease.validate(Platforms::CentOS)
    assert_nil pr

    assert_equal({:release=>["is invalid"]}, err.messages)

    pr, err = PlatformRelease.validate(Platforms::CentOS, "4")
    assert_nil pr

    assert_equal({:release=>["is invalid"]}, err.messages)

    pr, err = PlatformRelease.validate("centosh", "6")
    assert_nil pr

    assert_equal({:platform=>["is invalid"]}, err.messages)

    pr, err = PlatformRelease.validate(Platforms::CentOS, "7")
    assert_nil err

    assert_equal "centos", pr.platform
    assert_equal "7", pr.release

    pr, err = PlatformRelease.validate(Platforms::CentOS, "6")
    assert_nil err

    assert_equal "centos", pr.platform
    assert_equal "6", pr.release

    pr, err = PlatformRelease.validate(Platforms::CentOS, "5")
    assert_nil err

    assert_equal "centos", pr.platform
    assert_equal "5", pr.release

  end


  it "should work for ubuntu" do
    pr, err = PlatformRelease.validate(Platforms::Ubuntu)
    assert_nil pr

    assert_equal({:release=>["is invalid"]}, err.messages)


    pr, err = PlatformRelease.validate(Platforms::Ubuntu, "16.05")
    assert_nil pr

    assert_equal({:release=>["is invalid"]}, err.messages)


    pr, err = PlatformRelease.validate(Platforms::Ubuntu, "16.04")
    assert_nil err

    assert_equal "ubuntu", pr.platform
    assert_equal "xenial", pr.release


    pr, err = PlatformRelease.validate(Platforms::Ubuntu, "16.04.3")
    assert_nil err

    assert_equal "ubuntu", pr.platform
    assert_equal "xenial", pr.release

  end

   it "should work for debian" do
    pr, err = PlatformRelease.validate(Platforms::Debian)
    assert_nil pr

    assert_equal({:release=>["is invalid"]}, err.messages)


    pr, err = PlatformRelease.validate(Platforms::Debian, "8.5")
    assert_nil pr

    assert_equal({:release=>["is invalid"]}, err.messages)


    pr, err = PlatformRelease.validate(Platforms::Debian, "8")
    assert_nil err

    assert_equal "debian", pr.platform
    assert_equal "jessie", pr.release
  end


end
