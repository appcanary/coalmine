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

# A package is unique across (name, platform, release, version)
class Package < ActiveRecord::Base
  has_many :pallets, :through => :package_set

  def vulnerable?
    self.vulnerabilities.present?
  end
end
