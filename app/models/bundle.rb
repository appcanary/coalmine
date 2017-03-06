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
  extend ArchiveBehaviour
  # needed for archive methods
  def self.archive_class
    BundleArchive
  end


  belongs_to :account
  belongs_to :agent_server
  has_many :bundled_packages, :dependent => :destroy
  has_many :packages, :through => :bundled_packages
  has_many :vulnerable_packages, :through => :bundled_packages
  has_many :vulnerable_dependencies, :through => :vulnerable_packages

  has_many :log_bundle_vulnerabilities
  has_many :log_bundle_patches

  has_many :log_resolutions, ->(bundle) { where(account_id: bundle.account_id) }, :through => :bundled_packages

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

  scope :system_bundles, -> { where("platform IN (?)", Platforms::OPERATING_SYSTEMS) }
  scope :app_bundles, -> { where("platform NOT IN (?)", Platforms::OPERATING_SYSTEMS) }
  scope :created_on, -> (date) {
    where('valid_at >= ? and valid_at <= ?', date.at_beginning_of_day, date.at_end_of_day)
  }


  # TODO: change this method to affected?
  # deeply confusing when using BundlePresenter, which is VQ aware
  #
  # vuln at all is used by many serializers
  # to be determined if they should all switch to VulnQuery
  def vulnerable?
    affected_packages.select(1).limit(1).any?
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

  def system_bundle?
    Platforms::OPERATING_SYSTEMS.include?(self.platform)
  end
end
