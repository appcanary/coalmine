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
# Indexes
#
#  index_advisories_on_expired_at          (expired_at)
#  index_advisories_on_identifier          (identifier)
#  index_advisories_on_queued_advisory_id  (queued_advisory_id)
#  index_advisories_on_valid_at            (valid_at)
#

class Advisory < ActiveRecord::Base
  has_many :advisory_vulnerabilities
  has_many :vulnerabilities, :through => :advisory_vulnerabilities

  scope :most_recent_advisory_for, ->(identifier, source) {
    where(:identifier => identifier, :source => source).order("created_at DESC").limit(1)
  }

  scope :from_rubysec, -> {
    where(:source => RubysecImporter::SOURCE)
  }

  scope :from_cesa, -> {
    where(:source => CesaImporter::SOURCE)
  }

  scope :from_alas, -> {
    where(:source => AlasImporter::SOURCE)
  }

  scope :from_ubuntu, -> {
    where(:source => UbuntuTrackerImporter::SOURCE)
  }

   scope :from_debian, -> {
    where(:source => DebianTrackerImporter::SOURCE)
  }

  def to_vuln_attributes
    valid_attr = Vulnerability.attribute_names
    self.attributes.keep_if { |k, _| valid_attr.include?(k) }
  end

  def to_advisory_attributes
    self.attributes.except("id").merge(:advisory_id => self.id)
  end

  def relevant_attributes
    self.attributes.except("id", "updated_at", "created_at", "valid_at", "expired_at")
  end
end
