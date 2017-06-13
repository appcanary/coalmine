# == Schema Information
#
# Table name: vulnerable_packages
#
#  id                       :integer          not null, primary key
#  package_id               :integer          not null
#  vulnerable_dependency_id :integer          not null
#  vulnerability_id         :integer          not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  valid_at                 :datetime         not null
#  expired_at               :datetime         default("infinity"), not null
#
# Indexes
#
#  index_vulnerable_packages_on_expired_at                (expired_at)
#  index_vulnerable_packages_on_package_id                (package_id)
#  index_vulnerable_packages_on_valid_at                  (valid_at)
#  index_vulnerable_packages_on_vulnerability_id          (vulnerability_id)
#  index_vulnerable_packages_on_vulnerable_dependency_id  (vulnerable_dependency_id)
#  index_vulnpackage_packages                             (package_id,vulnerable_dependency_id,vulnerability_id) UNIQUE
#

require 'test_helper'

class VulnerablePackageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
