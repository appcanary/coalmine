# == Schema Information
#
# Table name: queued_advisories
#
#  id               :integer          not null, primary key
#  identifier       :string           not null
#  package_platform :string           not null
#  package_names    :string           default("{}"), not null, is an Array
#  patched          :jsonb            default("[]"), not null
#  affected         :jsonb            default("[]"), not null
#  unaffected       :jsonb            default("[]"), not null
#  title            :string
#  description      :text
#  criticality      :string
#  cve_ids          :string           default("{}"), not null, is an Array
#  osvdb_id         :string
#  usn_id           :string
#  dsa_id           :string
#  rhsa_id          :string
#  cesa_id          :string
#  alas_id          :string
#  debianbug        :string
#  source           :string
#  reported_at      :datetime
#  created_at       :datetime         not null
#
# Indexes
#
#  index_queued_advisories_on_identifier  (identifier)
#

class QueuedAdvisory < ActiveRecord::Base
  def to_advisory_attributes
    self.attributes.except("id").merge(:queued_advisory_id => self.id)
  end
end
