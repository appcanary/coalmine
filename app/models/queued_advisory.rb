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

  scope :most_recent_advisory_per, ->(source) {
    select("q1.*").from("queued_advisories q1 inner join 
                        (select identifier, MAX(created_at) as created_at from queued_advisories inner_q group by identifier) q2 
                        on q1.identifier = q2.identifier AND q1.created_at = q2.created_at").
                        where("q1.source = ?", source)
  }

  scope :most_recent_advisory_for, ->(identifier, source) {
    where(:identifier => identifier, :source => source).order("created_at DESC").limit(1)
  }

  scope :from_rubysec, -> {
    where(:source => RubysecImporter::SOURCE)
  }

  scope :from_cesa, -> {
    where(:source => CesaImporter::SOURCE)
  }


  def relevant_attributes
    self.attributes.except("id", "created_at")
  end
  def to_advisory_attributes
    self.attributes.except("id").merge(:queued_advisory_id => self.id)
  end
end
