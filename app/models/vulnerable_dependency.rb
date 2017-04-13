# == Schema Information
#
# Table name: vulnerable_dependencies
#
#  id                  :integer          not null, primary key
#  vulnerability_id    :integer          not null
#  platform            :string           not null
#  release             :string
#  package_name        :string           not null
#  arch                :string
#  patched_versions    :text             default("{}"), not null, is an Array
#  unaffected_versions :text             default("{}"), not null, is an Array
#  pending             :boolean          default("false"), not null
#  end_of_life         :boolean          default("false"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  valid_at            :datetime         not null
#  expired_at          :datetime         default("infinity"), not null
#  affected_versions   :string           default("{}"), not null, is an Array
#  text                :string           default("{}"), not null, is an Array
#
# Indexes
#
#  index_vulnerable_dependencies_on_expired_at                 (expired_at)
#  index_vulnerable_dependencies_on_package_name               (package_name)
#  index_vulnerable_dependencies_on_platform                   (platform)
#  index_vulnerable_dependencies_on_platform_and_package_name  (platform,package_name)
#  index_vulnerable_dependencies_on_valid_at                   (valid_at)
#  index_vulnerable_dependencies_on_vulnerability_id           (vulnerability_id)
#

class VulnerableDependency < ActiveRecord::Base
  extend ArchiveBehaviour
  belongs_to :vulnerability
  has_many :vulnerable_packages, :dependent => :destroy
  has_many :log_resolutions

  validates :vulnerability_id, :presence => true
  validates :platform, :presence => true
  validates :package_name, :presence => true

  validate :affected_or_patched_not_both

  # Patchable is now a bit of a hack/misnomer based on shoe-horning PHP
  # advisories into this mould. PHP advisories only have affected version
  # constraints, and not patched versions or unaffected versions. So, we modify
  # the "patchable" scope to include any VDs which have non-empty affected
  # versions, because as of right now, this is a proxy for PHP. Otherwise, in
  # order to make these VDs show up we would need account.notify_everything to
  # be set.

  # Here's @phillmv's comments from slack for the historical record:

  # now vuln query has to understand platforms
  # i think this is a gordian knot that can just be cut
  # patchable doesn’t make sense with the php data
  # so both patchable and affected just give you the same result
  # and therefore vulnquery doesn’t need to change
  # it’ll silently Just Work for every platform
  # and then we’ve successfully punted the problem until we import a
  # future dataset that also has affected
  # if PHP forever remains the sole platform that uses affected ¯\_(ツ)_/¯

  scope :patchable, -> { 
    where("vulnerable_dependencies.affected_versions != '{}'
           OR NOT (vulnerable_dependencies.patched_versions = '{}'
                   AND vulnerable_dependencies.unaffected_versions = '{}')")
  }

  scope :unpatchable, -> { 
    where("(vulnerable_dependencies.patched_versions = '{}' 
          AND vulnerable_dependencies.unaffected_versions = '{}')")
  }


  delegate :title, :criticality, :to => :vulnerability, :prefix => true
  
  # strictly, is this a package from the same platform, release, arch?
  #
  def concerns?(package)
    # are they the same platform?
    return false if self.platform != package.platform

    # they are the same platform,
    # are they the same release (if we have a release)
    return false if self.release.present? && self.release != package.release

    # release is good,
    # are they the same arch (if we have an arch)
    return false if self.arch.present? && self.arch != package.arch

    # arch is good,
    # does the package have the right name?
    return package.same_name?(self.package_name)
  end

  # whether this package could be vulnerable

  # N_A?  B_P?  A?    Vuln?
  # T     T     T     T
  # T     F     T     T
  # F     T     T     T
  # F     F     T     T
  # T     T     F     F
  # T     F     F     F
  # F     T     F     F
  # F     F     F     T
  #
  # i.e. A? || !(N_A? || B_P?)

  def affects?(package)
    return false unless concerns?(package)

    # a package is vulnerable if it's in the affected_versions OR
    # it's not in the unaffected_versions AND
    # it's not been patched

    # this seems superficially like a dumb proxy for PHP, but it
    # also seems reasonable to skip additional checks if there's
    # a list of affected_versions

    if affected_versions.empty?
      !(package.not_affected?(unaffected_versions) ||
        package.been_patched?(patched_versions))
    else
      package.affected?(affected_versions)
    end
  end

  def patchable?
    self.patched_versions.present? || self.unaffected_versions.present?
  end

  # used to filter and select collections of 
  # vuln_deps within the VulnManager
  def unique_hash
    @unique_hash ||= self.attributes.except("id", "pending", "end_of_life", "created_at", "updated_at", "valid_at", "expired_at")
  end

  def affected_or_patched_not_both
    if affected_versions.present? && (patched_versions.present? || unaffected_versions.present?)
      errors.add(:affected_versions, "can't coexist with patched or unaffected versions")
    end
  end
end
