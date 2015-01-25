# == Schema Information
#
# Table name: beta_users
#
#  id         :integer          not null, primary key
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BetaUser < ActiveRecord::Base
end
