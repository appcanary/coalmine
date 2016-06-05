# == Schema Information
#
# Table name: bundle_patches
#
#  id                    :integer          not null, primary key
#  bundle_id             :integer
#  vulnerable_package_id :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class BundlePatch < ActiveRecord::Base
  belongs_to :bundle
  belongs_to :vulnerable_package
end
