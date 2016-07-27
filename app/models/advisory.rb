# == Schema Information
#
# Table name: advisories
#
#  id                  :integer          not null, primary key
#  queued_advisory_id  :integer          not null
#  identifier          :string           not null
#  package_platform    :string           not null
#  package_names       :string           default("{}"), not null, is an Array
#  affected_arches     :string           default("{}"), not null, is an Array
#  affected_releases   :string           default("{}"), not null, is an Array
#  patched_versions    :text             default("{}"), not null, is an Array
#  unaffected_versions :text             default("{}"), not null, is an Array
#  title               :string
#  description         :text
#  criticality         :string
#  cve_ids             :string           default("{}"), not null, is an Array
#  osvdb_id            :string
#  usn_id              :string
#  dsa_id              :string
#  rhsa_id             :string
#  cesa_id             :string
#  source              :string
#  reported_at         :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  valid_at            :datetime         not null
#  expired_at          :datetime         default("infinity"), not null
#

class Advisory < ActiveRecord::Base
  belongs_to :queued_advisory
  has_many :advisory_vulnerabilities
  has_many :vulnerabilities, :through => :advisory_vulnerabilities

  def to_vuln_attributes
    valid_attr = Vulnerability.attribute_names
    self.attributes.keep_if { |k, _| valid_attr.include?(k) }
  end
end
