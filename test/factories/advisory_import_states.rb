# == Schema Information
#
# Table name: advisory_import_states
#
#  id          :integer          not null, primary key
#  advisory_id :integer          not null
#  processed   :boolean          default("false"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_advisory_import_states_on_advisory_id  (advisory_id)
#

FactoryGirl.define do
  factory :advisory_import_state do
    advisory nil
processed false
  end

end
