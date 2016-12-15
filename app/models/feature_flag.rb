# == Schema Information
#
# Table name: feature_flags
#
#  id         :integer          not null, primary key
#  data       :hstore
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_feature_flags_on_data  (data)
#

class FeatureFlag < ActiveRecord::Base
end
