# == Schema Information
#
# Table name: log_bundle_patches
#
#  id                    :integer          not null, primary key
#  bundle_id             :integer
#  package_id            :integer
#  bundled_package_id    :integer
#  vulnerability_id      :integer
#  vulnerable_package_id :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class LogBundlePatch < ActiveRecord::Base
  belongs_to :bundle
  belongs_to :vulnerable_package
end
