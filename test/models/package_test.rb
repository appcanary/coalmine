# == Schema Information
#
# Table name: packages
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  source_name     :string
#  platform        :string
#  release         :string
#  version         :string
#  version_release :string
#  epoch           :string
#  arch            :string
#  filename        :string
#  checksum        :string
#  origin          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  valid_at        :datetime         not null
#  expired_at      :datetime         default("infinity"), not null
#
# Indexes
#
#  index_packages_on_expired_at                                 (expired_at)
#  index_packages_on_name_and_version_and_platform_and_release  (name,version,platform,release)
#  index_packages_on_valid_at                                   (valid_at)
#

require 'test_helper'

class PackageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end