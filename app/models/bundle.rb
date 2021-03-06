# == Schema Information
#
# Table name: bundles
#
#  id              :integer          not null, primary key
#  account_id      :integer          not null
#  agent_server_id :integer
#  name            :string
#  path            :string
#  platform        :string           not null
#  release         :string
#  last_crc        :integer
#  being_watched   :boolean
#  from_api        :boolean
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  valid_at        :datetime         not null
#  expired_at      :datetime         default("infinity"), not null
#
# Indexes
#
#  index_bundles_on_account_id                               (account_id)
#  index_bundles_on_account_id_and_agent_server_id           (account_id,agent_server_id)
#  index_bundles_on_account_id_and_agent_server_id_and_path  (account_id,agent_server_id,path)
#  index_bundles_on_agent_server_id                          (agent_server_id)
#  index_bundles_on_expired_at                               (expired_at)
#  index_bundles_on_from_api                                 (from_api)
#  index_bundles_on_valid_at                                 (valid_at)
#

class Bundle < ActiveRecord::Base
  extend ArchiveBehaviour::BaseModel

  belongs_to :account
  belongs_to :agent_server
  has_many :bundled_packages, :dependent => :delete_all
  has_many :packages, :through => :bundled_packages
  has_many :vulnerable_packages, :through => :bundled_packages
  has_many :vulnerable_dependencies, :through => :vulnerable_packages

  has_many :log_bundle_vulnerabilities
  has_many :log_bundle_patches

  has_many :log_resolutions, ->(bundle) { where(account_id: bundle.account_id) }, :through => :bundled_packages
  has_many :ignored_packages, :dependent => :destroy

  validates :account, presence: true
  validates :name, uniqueness: { scope: :account_id }, unless: ->(u){ u.path.present? }

  scope :belonging_to, -> (user) {
    where(:account_id => user.account_id)
  }

  scope :via_active_agent, -> {
    joins(:agent_server).merge(AgentServer.active)
  }

  # TODO: elimite from_api
  scope :via_api, -> { where("bundles.agent_server_id is null") }

  scope :via_agent, -> { where("bundles.agent_server_id is not null") }

  scope :system_bundles, -> { where("bundles.platform IN (?)", Platforms::OPERATING_SYSTEMS) }
  scope :app_bundles, -> { where("bundles.platform NOT IN (?)", Platforms::OPERATING_SYSTEMS) }

  # note that these are instance methods
  # as opposed to ArchiveBehaviour class methods
  def as_of(date)
    bq = BundleQuery.new(self, date);
  end

  def revisions
    BundledPackage.revisions.where(:bundle_id => self.id).pluck("distinct(valid_at)")
  end

  def ignored_packages
    IgnoredPackage.relevant_ignores_for(self)
  end

  # TODO: change this method to affected?
  # deeply confusing when using BundlePresenter, which is VQ aware
  #
  # vuln at all is used by many serializers
  # to be determined if they should all switch to VulnQuery
  def vulnerable?
    affected_packages.select(1).limit(1).any?
  end

  # See the TODO above.
  # We should decide if we switch vulnerable? above to use vulnquery. As a stopgap, this method.
  def vulnerable_via_vulnquery?
    VulnQuery.new(self.account).vuln_bundle?(self)
  end

  def patchable?
    patchable_packages.select(1).limit(1).any?
  end

  def vulnerable_status
    if patchable?
      :patchable
    elsif vulnerable?
      :vulnerable
    else
      false
    end
  end

  def affected_packages
    self.packages.affected
  end

  def patchable_packages
    self.packages.affected_but_patchable
  end

  # TODO: this should be in the presenter
  def display_name
    if agent_server_id.present? and self.system_bundle?
      "System Packages"
    else
      name.blank? ? path : name
    end
  end

  def tags
    if self.agent_server
      self.agent_server.tags.map(&:tag)
    else
      []
    end
  end


  #--- USED only for 'MasterReporter'

  def ref_name
    if agent_server_id.present? and self.system_bundle?
      agent_server.display_name
    else
      name.blank? ? path : name
    end
  end

  def isactive?
    if agent_server_id.present?
      !agent_server.gone_silent?
    else
      true
    end
  end

  def system_bundle?
    Platforms::OPERATING_SYSTEMS.include?(self.platform)
  end

end
