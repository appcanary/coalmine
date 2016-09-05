# == Schema Information
#
# Table name: advisories
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
#  related          :jsonb            default("[]"), not null
#  cve_ids          :string           default("{}"), not null, is an Array
#  osvdb_id         :string
#  usn_id           :string
#  dsa_id           :string
#  rhsa_id          :string
#  cesa_id          :string
#  source_text      :text
#  source           :string           not null
#  processed        :boolean          default("false"), not null
#  reported_at      :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  valid_at         :datetime         not null
#  expired_at       :datetime         default("infinity"), not null
#
# Indexes
#
#  index_advisories_on_expired_at  (expired_at)
#  index_advisories_on_identifier  (identifier)
#  index_advisories_on_processed   (processed)
#  index_advisories_on_source      (source)
#  index_advisories_on_valid_at    (valid_at)
#

require 'test_helper'

class AdvisoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
