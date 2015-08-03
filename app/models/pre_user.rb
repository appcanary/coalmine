# == Schema Information
#
# Table name: pre_users
#
#  id         :integer          not null, primary key
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PreUser < ActiveRecord::Base
end
