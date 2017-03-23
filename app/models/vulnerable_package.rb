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
#

class VulnerablePackage < ActiveRecord::Base
  belongs_to :package
  belongs_to :vulnerable_dependency

  # vulnerability link is purely for bookkeeping convenience
  # TODO: carefully explain this relationship
  belongs_to :vulnerability

  has_many :bundled_packages
  has_many :bundles, :through => :bundled_packages

  has_many :log_resolutions, :foreign_key => :vulnerable_dependency_id, :primary_key => :vulnerable_dependency_id

  delegate :name, :source_name, :platform, :release, :version, :upgrade_to, :to => :package

  scope :distinct_package, -> { 
    select("distinct(vulnerable_packages.package_id), vulnerable_packages.*")
  }

  def unique_hash
    @unique_hash ||= self.attributes.except("id", "created_at", "updated_at", "valid_at", "expired_at")
  end

end
