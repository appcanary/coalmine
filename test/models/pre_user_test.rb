# == Schema Information
#
# Table name: pre_users
#
#  id                 :integer          not null, primary key
#  email              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  preferred_platform :string
#

require 'test_helper'

class PreUserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
