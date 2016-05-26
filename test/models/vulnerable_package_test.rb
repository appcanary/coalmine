# == Schema Information
#
# Table name: vulnerable_packages
#
#  id               :integer          not null, primary key
#  package_id       :integer
#  vulnerability_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'test_helper'

class VulnerablePackageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
