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
  has_many :bundled_packages
  has_many :bundles, :through => :bundled_packages

  def concerning_vulnerabilities
    # TODO: what do we store exactly on Vulns,
    # i.e. do we store name, platform, release?
    Vulnerability.where(:package_name => name,
                        :package_platform => platform)
  end
end
