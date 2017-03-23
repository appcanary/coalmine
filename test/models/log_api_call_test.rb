# == Schema Information
#
# Table name: log_api_calls
#
#  id         :integer          not null, primary key
#  account_id :integer
#  action     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  platform   :string
#  release    :string
#
# Indexes
#
#  index_log_api_calls_on_action  (action)
#

require 'test_helper'

class LogApiCallTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
