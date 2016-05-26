# == Schema Information
#
# Table name: packages
#
#  id         :integer          not null, primary key
#  name       :string
#  platform   :string
#  release    :string
#  version    :string
#  artifact   :string
#  epoch      :string
#  arch       :string
#  filename   :string
#  checksum   :string
#  origin     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class PackageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
