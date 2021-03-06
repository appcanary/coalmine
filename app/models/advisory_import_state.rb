# == Schema Information
#
# Table name: advisory_import_states
#
#  id              :integer          not null, primary key
#  advisory_id     :integer          not null
#  processed       :boolean          default("false"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  processed_count :integer          default("0")
#
# Indexes
#
#  index_advisory_import_states_on_advisory_id  (advisory_id)
#

class AdvisoryImportState < ActiveRecord::Base
  belongs_to :advisory
end
