# == Schema Information
#
# Table name: motds
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  subject    :string
#  body       :text             not null
#  remove_at  :datetime         not null
#  position   :string           default("header")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_motds_on_remove_at  (remove_at)
#

class Motd < ActiveRecord::Base
end
