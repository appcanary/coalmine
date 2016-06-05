# == Schema Information
#
# Table name: packages_package_sets
#
#  id             :integer          not null, primary key
#  package_set_id :integer
#  package_id     :integer
#  vulnerable     :boolean          default("f"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class BundledPackage < ActiveRecord::Base
  belongs_to :package
  belongs_to :bundle
end
