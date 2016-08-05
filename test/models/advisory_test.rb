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

require 'test_helper'

class AdvisoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
