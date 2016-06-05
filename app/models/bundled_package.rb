# == Schema Information
#
# Table name: bundled_packages
#
#  id         :integer          not null, primary key
#  bundle_id  :integer
#  package_id :integer
#  vulnerable :boolean          default("f"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BundledPackage < ActiveRecord::Base
  belongs_to :package
  belongs_to :bundle
end
