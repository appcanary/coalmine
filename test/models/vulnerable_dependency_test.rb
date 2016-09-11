# == Schema Information
#
# Table name: vulnerable_dependencies
#
#  id                  :integer          not null, primary key
#  vulnerability_id    :integer          not null
#  package_platform    :string           not null
#  package_name        :string           not null
#  release             :string
#  arch                :string
#  patched_versions    :text             default("{}"), not null, is an Array
#  unaffected_versions :text             default("{}"), not null, is an Array
#  pending             :boolean          default("false"), not null
#  end_of_life         :boolean          default("false"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  valid_at            :datetime         not null
#  expired_at          :datetime         default("infinity"), not null
#
# Indexes
#
#  index_vulnerable_dependencies_on_expired_at  (expired_at)
#  index_vulnerable_dependencies_on_valid_at    (valid_at)
#

require 'test_helper'

class VulnerableDependencyTest < ActiveSupport::TestCase
  it "should correctly calculate vuln ruby packages" do

    name = "fakemcfake"
    vuln_dep = FactoryGirl.build(:vulnerable_dependency, 
                                 :package_platform => Platforms::Ruby, 
                                 :package_name => name, 
                                 :patched_versions => [">= 1.10"], 
                                 :unaffected_versions => ["~> 1.9.2", "< 1.7.0"])

    patched_pkg = build_rpkg(name, "1.10")

    # less than 1.7.0
    un_pkg1 = build_rpkg(name, "1.6.0")
    # same minor version as 1.9.2
    un_pkg2 = build_rpkg(name, "1.9.3")

    # lower than 1.9.2
    vuln_pkg1 = build_rpkg(name, "1.9.1")
    vuln_pkg2 = build_rpkg(name, "1.8.0")

    diff_pkg = build_rpkg(name+"lol", "1.9.1")



    refute vuln_dep.affects?(patched_pkg), "patched should not be vuln"
    refute vuln_dep.affects?(un_pkg1), "unaffected should not be vuln"
    refute vuln_dep.affects?(un_pkg2), "unaffected should not be vuln"
    assert vuln_dep.affects?(vuln_pkg1), "vuln pkg should be vuln"
    assert vuln_dep.affects?(vuln_pkg2), "vuln pkg should be vuln"
    refute vuln_dep.affects?(diff_pkg), "pkg w/diff name should not be vuln"
  end

  # TODO: affected releases, affected arches?
  it "should correctly calculate vuln centos packages" do
    name = "openssh"

    vuln_dep = FactoryGirl.build(:vulnerable_dependency, 
                                 :package_platform => Platforms::CentOS,
                                 :package_name => name, 
                                 :patched_versions =>  ["openssh-6.6.1p1-25.el7_2.src.rpm", "openssh-6.6.1p1-25.el7_2.x86_64.rpm"],
                                 :unaffected_versions => [])

    # exact same version
    patched_pkg1 = build_cpkg(name, "openssh-6.6.1p1-25.el7_2.x86_64.rpm")
    # higher version
    patched_pkg2 = build_cpkg(name, "openssh-6.7.1p1-23.el7_2.x86_64")

    # higher release
    patched_pkg3 = build_cpkg(name, "openssh-6.6.1p1-26.el7_2.x86_64")
    patched_pkg4 = build_cpkg(name, "openssh-6.6.1p1-25.el7_3.x86_64")


    # release is lower
    vuln_pkg1 = build_cpkg(name, "openssh-6.6.1p1-23.el7_2.x86_64")
    vuln_pkg2 = build_cpkg(name, "openssh-6.6.1p1-25.el7_1.x86_64")
    vuln_pkg3 = build_cpkg(name, "openssh-6.6.1p1-25.el7.x86_64")
    # version is lower
    vuln_pkg4 = build_cpkg(name, "openssh-6.6.1p0-25.el7_2.x86_64")

    diff_pkg = build_cpkg(name+"lol", vuln_pkg1.version)

    refute vuln_dep.affects?(patched_pkg1), "patched should not be vuln"
    refute vuln_dep.affects?(patched_pkg2), "patched should not be vuln"
    refute vuln_dep.affects?(patched_pkg3), "patched should not be vuln"
    refute vuln_dep.affects?(patched_pkg4), "patched should not be vuln"
    assert vuln_dep.affects?(vuln_pkg1), "vuln pkg should be vuln"
    assert vuln_dep.affects?(vuln_pkg2), "vuln pkg should be vuln"
    assert vuln_dep.affects?(vuln_pkg3), "vuln pkg should be vuln"
    assert vuln_dep.affects?(vuln_pkg4), "vuln pkg should be vuln"
    refute vuln_dep.affects?(diff_pkg), "pkg w/diff name should not be vuln"
  end


  it "should flag things as vulnerable when they match the same release" do
    name = "openssl"

    vuln_dep = FactoryGirl.build(:vulnerable_dependency,
                                 package_platform: Platforms::Debian,
                                 package_name: name,
                                 release: "jessie",
                                 patched_versions: [])

    pkg = build_dpkg(name, "1.0.1t-1+deb8u2")

    assert vuln_dep.affects?(pkg)
  end

  def build_cpkg(name, ver)
    FactoryGirl.build(:package, :centos,
                      :name => name,
                      :version => ver)

  end

  def build_rpkg(name, ver)
    FactoryGirl.build(:package, :ruby,
                      :name => name,
                      :version => ver)
  end

  def build_dpkg(name, ver)
    FactoryGirl.build(:package, :debian,
                      :name => name,
                      :version => ver)
  end


  
end
