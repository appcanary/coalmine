# == Schema Information
#
# Table name: vulnerabilities
#
#  id               :integer          not null, primary key
#  package_platform :string           not null
#  title            :string
#  description      :text
#  criticality      :string
#  cve_ids          :string           default("{}"), not null, is an Array
#  osvdb_id         :string
#  usn_id           :string
#  dsa_id           :string
#  rhsa_id          :string
#  cesa_id          :string
#  source           :string
#  reported_at      :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  valid_at         :datetime         not null
#  expired_at       :datetime         default("infinity"), not null
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

    patched_pkg = FactoryGirl.build(:package, :ruby, 
                                    :name => name, :version => "1.10")
    un_pkg = FactoryGirl.build(:package, :ruby, 
                              :name => name, :version => "1.6.0")
    un_pkg2 = FactoryGirl.build(:package, :ruby, 
                               :name => name, :version => "1.9.3")

    vuln_pkg = FactoryGirl.build(:package, :ruby, 
                                :name => name, :version => "1.9.1")

    diff_pkg = FactoryGirl.build(:package, :ruby, 
                                :name => name+"lol", :version => "1.9.1")



    refute vuln_dep.affects?(patched_pkg), "patched should not be vuln"
    refute vuln_dep.affects?(un_pkg), "unaffected should not be vuln"
    refute vuln_dep.affects?(un_pkg2), "unaffected should not be vuln"
    assert vuln_dep.affects?(vuln_pkg), "vuln pkg should be vuln"
    refute vuln_dep.affects?(diff_pkg), "pkg w/diff name should not be vuln"
  end

  it "should correctly calculate vuln centos packages" do
    name = "wpa_supplicant"

    vuln_dep = FactoryGirl.build(:vulnerable_dependency, 
                                 :package_platform => Platforms::CentOS, 
                                 :package_name => name, 
                                 :patched_versions =>  ["wpa_supplicant-2.0-17.el7_1.src.rpm", "wpa_supplicant-2.0-17.el7_1.x86_64.rpm"],
                                 :unaffected_versions => [])

    patched_pkg = FactoryGirl.build(:package, :centos,
                                    :name => name,
                                    :version => "3.7.1-17.el7.arch")

    vuln_pkg = FactoryGirl.build(:package, :centos,
                                 :name => name,
                                 :version => "3.7.0-11.el7.arch")

    diff_pkg = FactoryGirl.build(:package, :centos,
                                 :name => name+"lol",
                                 :version => "3.7.0-17.el7.arch")

    refute vuln_dep.affects?(patched_pkg), "patched should not be vuln"
    assert vuln_dep.affects?(vuln_pkg), "vuln pkg should be vuln"
    refute vuln_dep.affects?(diff_pkg), "pkg w/diff name should not be vuln"
  end
  
end
