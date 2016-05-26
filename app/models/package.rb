# == Schema Information
#
# Table name: packages
#
#  id          :integer          not null, primary key
#  name        :string
#  source_name :string
#  platform    :string
#  release     :string
#  version     :string
#  artifact    :string
#  epoch       :string
#  arch        :string
#  filename    :string
#  checksum    :string
#  origin      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

# A package is unique across (name, platform, release, version)
class Package < ActiveRecord::Base
  has_many :packages_package_sets
  has_many :package_sets, :through => :packages_package_sets

  def concerning_vulnerabilties
    # TODO: what do we store exactly on Vulns,
    # i.e. do we store name, platform, release?
    etc = "..."
    Vulnerability.where(etc)
  end
end
