# == Schema Information
#
# Table name: packages
#
#  id             :integer          not null, primary key
#  platform       :string           not null
#  release        :string
#  name           :string           not null
#  version        :string
#  source_name    :string
#  source_version :string
#  epoch          :string
#  arch           :string
#  filename       :string
#  checksum       :string
#  origin         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  valid_at       :datetime         not null
#  expired_at     :datetime         default("infinity"), not null
#
# Indexes
#
#  index_packages_on_expired_at                                 (expired_at)
#  index_packages_on_name_and_version_and_platform_and_release  (name,version,platform,release)
#  index_packages_on_valid_at                                   (valid_at)
#

require 'test_helper'

class PackageTest < ActiveSupport::TestCase
  test "whether concerning_vulnerabilities works" do
    package1 = FactoryGirl.build(:package, :debian,
                                 :name => "openssh-client",
                                 :source_name => "openssh",
                                 :version => "2.0.0")


    assert_equal 0, package1.concerning_vulnerabilities.count
    package2 = FactoryGirl.build(:package, :debian,
                                 :name => "openssh",
                                 :version => "2.0.0")

    assert_equal 0, package2.concerning_vulnerabilities.count

    v = FactoryGirl.create(:vulnerability, :debian,
                          :deps => [])
    vd = FactoryGirl.create(:vulnerable_dependency,
                            :vulnerability => v,
                            :platform => Platforms::Debian,
                            :release => "jessie",
                            :package_name => "openssh",
                            :patched_versions => ["1.0.0"])

    vd2 = FactoryGirl.create(:vulnerable_dependency,
                             :vulnerability => v,
                             :platform => Platforms::Debian,
                             :release => "jessie",
                             :package_name => "openssh1",
                             :patched_versions => ["1.0.0"])


    assert_equal 1, package1.concerning_vulnerabilities.count
    assert_equal 1, package2.concerning_vulnerabilities.count

  end
end
