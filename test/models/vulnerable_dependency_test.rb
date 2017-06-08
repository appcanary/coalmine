# == Schema Information
#
# Table name: vulnerable_dependencies
#
#  id                  :integer          not null, primary key
#  vulnerability_id    :integer          not null
#  platform            :string           not null
#  release             :string
#  package_name        :string           not null
#  arch                :string
#  patched_versions    :text             default("{}"), not null, is an Array
#  unaffected_versions :text             default("{}"), not null, is an Array
#  pending             :boolean          default("false"), not null
#  end_of_life         :boolean          default("false"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  valid_at            :datetime         not null
#  expired_at          :datetime         default("infinity"), not null
#  affected_versions   :string           default("{}"), not null, is an Array
#  text                :string           default("{}"), not null, is an Array
#
# Indexes
#
#  index_vulnerable_dependencies_on_expired_at                 (expired_at)
#  index_vulnerable_dependencies_on_package_name               (package_name)
#  index_vulnerable_dependencies_on_platform                   (platform)
#  index_vulnerable_dependencies_on_platform_and_package_name  (platform,package_name)
#  index_vulnerable_dependencies_on_valid_at                   (valid_at)
#  index_vulnerable_dependencies_on_vulnerability_id           (vulnerability_id)
#

require 'test_helper'

class VulnerableDependencyTest < ActiveSupport::TestCase
  it "should correctly calculate vuln ruby packages" do

    name = "fakemcfake"
    vuln_dep = FactoryGirl.build(:vulnerable_dependency, 
                                 :platform => Platforms::Ruby, 
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

  it "should correctly calculate vuln php packages" do
    name = "fakemcfake"
    vuln_dep = FactoryGirl.build(:vulnerable_dependency,
                                 :platform => Platforms::PHP,
                                 :package_name => name,
                                 :unaffected_versions => [],
                                 :patched_versions => [],
                                 :affected_versions => [">=1.7.0,<1.10"])

    unaffected_pkg1 = build_ppkg(name, "1.11")
    unaffected_pkg2 = build_ppkg(name, "1.10.0")
    unaffected_pkg3 = build_ppkg(name, "1.6.10")

    # less than 1.7.0
    affected_pkg1 = build_ppkg(name, "1.7.0")
    affected_pkg2 = build_ppkg(name, "1.9.11")

    diff_pkg = build_ppkg(name+"lol", "1.7.1")

    refute vuln_dep.affects?(unaffected_pkg1), "unaffected should not be vuln"
    refute vuln_dep.affects?(unaffected_pkg2), "unaffected should not be vuln"
    refute vuln_dep.affects?(unaffected_pkg3), "unaffected should not be vuln"
    assert vuln_dep.affects?(affected_pkg1), "affected pkg should be vuln"
    assert vuln_dep.affects?(affected_pkg2), "affected pkg should be vuln"
    refute vuln_dep.affects?(diff_pkg), "pkg w/diff name should not be vuln"
  end

  # TODO: affected releases, affected arches?
  it "should correctly calculate vuln centos packages" do
    name = "openssh"

    vuln_dep = FactoryGirl.build(:vulnerable_dependency, 
                                 :platform => Platforms::CentOS,
                                 :package_name => name, 
                                 :release => "7",
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

  # TODO: affected releases, affected arches?
  describe "alpine linux" do
    it "should correctly calculate vuln packages" do
      name = "openssh"

      vuln_dep = FactoryGirl.build(:vulnerable_dependency,
                                   :platform => Platforms::Alpine,
                                   :package_name => name,
                                   :release => "3.5",
                                   :patched_versions =>  ["7.4_p1-r1"],
                                   :unaffected_versions => [])

      # exact same version
      patched_pkg1 = build_apkg(name, "7.4_p1-r1")
      # higher version
      patched_pkg2 = build_apkg(name, "7.5_p1-r1")

      # higher release
      patched_pkg3 = build_apkg(name, "7.4_p1-r2")
      patched_pkg4 = build_apkg(name, "7.4_p1-r3")


      # release is lower
      vuln_pkg1 = build_apkg(name, "7.4_p1-r0")
      # version is lower
      vuln_pkg2 = build_apkg(name, "7.3_p1-r1")

      diff_pkg = build_apkg(name+"lol", vuln_pkg1.version)

      refute vuln_dep.affects?(patched_pkg1), "patched should not be vuln"
      refute vuln_dep.affects?(patched_pkg2), "patched should not be vuln"
      refute vuln_dep.affects?(patched_pkg3), "patched should not be vuln"
      refute vuln_dep.affects?(patched_pkg4), "patched should not be vuln"
      assert vuln_dep.affects?(vuln_pkg1), "vuln pkg should be vuln"
      assert vuln_dep.affects?(vuln_pkg2), "vuln pkg should be vuln"
      refute vuln_dep.affects?(diff_pkg), "pkg w/diff name should not be vuln"
    end

    it "should correctly not find vulnerable packages from other releases" do
      name = "openssh"

      vuln_dep = FactoryGirl.build(:vulnerable_dependency,
                                   :platform => Platforms::Alpine,
                                   :package_name => name,
                                   :release => "3.4",
                                   :patched_versions =>  ["7.4_p1-r1"],
                                   :unaffected_versions => [])

      # OS release in factory is 3.5

      # release is lower
      pkg1 = build_apkg(name, "7.4_p1-r0")
      # version is lower
      pkg2 = build_apkg(name, "7.3_p1-r1")

      refute vuln_dep.affects?(pkg1), "different release should not be vuln"
      refute vuln_dep.affects?(pkg2), "different release should not be vuln"
    end
  end

  it "should flag things as vulnerable when they match the same release" do
    name = "openssl"

    vuln_dep = FactoryGirl.build(:vulnerable_dependency,
                                 platform: Platforms::Debian,
                                 package_name: name,
                                 release: "jessie",
                                 patched_versions: [])

    pkg = build_dpkg(name, "1.0.1t-1+deb8u2")

    assert vuln_dep.affects?(pkg)
  end

  def build_apkg(name, ver)
    build_pkg(:alpine, name, ver)
  end

  def build_cpkg(name, ver)
    build_pkg(:centos, name, ver)
  end

  def build_rpkg(name, ver)
    build_pkg(:ruby, name, ver)
  end

  def build_dpkg(name, ver)
    build_pkg(:debian, name, ver)
  end

  def build_ppkg(name, ver)
    build_pkg(:php, name, ver)
  end

  def build_pkg(type, name, ver)
    FactoryGirl.build(:package, type,
                      :name => name,
                      :version => ver)
  end
end
