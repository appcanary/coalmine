# == Schema Information
#
# Table name: agent_servers
#
#  id               :integer          not null, primary key
#  account_id       :integer
#  agent_release_id :integer
#  uuid             :uuid
#  hostname         :string
#  uname            :string
#  name             :string
#  ip               :string
#  distro           :string
#  release          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  valid_at         :datetime         not null
#  expired_at       :datetime         default("infinity"), not null
#
# Indexes
#
#  index_agent_servers_on_account_id        (account_id)
#  index_agent_servers_on_agent_release_id  (agent_release_id)
#  index_agent_servers_on_expired_at        (expired_at)
#  index_agent_servers_on_uuid              (uuid)
#  index_agent_servers_on_valid_at          (valid_at)
#

class AgentServer < ActiveRecord::Base
  extend ArchiveBehaviour::BaseModel

  ACTIVE_WINDOW = 2.hours
  belongs_to :account
  validates :account, :presence => true

  belongs_to :agent_release
  has_many :bundles, :dependent => :destroy
  has_many :bundles_with_vulnerable_affected, -> { merge(Bundle.with_vulnerable_affected) }, class_name: Bundle
  has_many :bundles_with_vulnerable_patchable, -> { merge(Bundle.with_vulnerable_patchable) }, class_name: Bundle

  has_many :heartbeats, :class_name => AgentHeartbeat
  has_many :received_files, :class_name => AgentReceivedFile
  has_many :accepted_files, :class_name => AgentAcceptedFile
  has_many :server_tags, :dependent => :destroy
  has_many :tags, :through => :server_tags

  has_many :server_processes, :dependent => :destroy

  has_one :last_heartbeat, -> { order(created_at: :desc).limit(1) }, :class_name => AgentHeartbeat, :foreign_key => :agent_server_id

  scope :include_last_heartbeats, -> {
    # If you do just an .includes(), the order by created_at limit 1 part is gone.
    # So, we have to scope the query ourselves
    subq = AgentHeartbeat.order(created_at: :desc).limit(1).where("agent_heartbeats.agent_server_id = agent_servers.id").select("id")
    includes(:last_heartbeat).where("agent_heartbeats.id = (#{subq.to_sql}) OR agent_heartbeats.id IS NULL").references(:agent_heartbeats)
  }

  scope :belonging_to, -> (user) {
    where(:account_id => user.account_id)
  }

  scope :active, -> {
    self.active_as_of(Time.now)
  }

  scope :inactive, -> {
    self.inactive_as_of(Time.now)
  }

  scope :active_as_of, ->(date) {
    include_last_heartbeats.where("agent_heartbeats.created_at >= ?", date - ACTIVE_WINDOW)
  }

  scope :inactive_as_of, ->(date) {
    include_last_heartbeats.where("(agent_heartbeats.created_at < ?) OR (agent_heartbeats.created_at IS NULL)", date - ACTIVE_WINDOW)
  }

  def bundles_with_vulnerable
    vq = VulnQuery.new(self.account)
    self.send(vq.bundles_with_vulnerable_scope)
  end

  def last_heartbeat_at
    last_heartbeat.try(:created_at)
  end

  def register_heartbeat!(params)
    self.transaction do
      self.heartbeats.create!(:files => params[:files])

      agent_version = params[:"agent-version"]
      self.agent_release = AgentRelease.where(:version => agent_version).first_or_create!
      self.save!
    end
  end

  def idempotently_add_tags!(tags)
    self.transaction do
      self.destructively_update_tags!((tags + self.tags.pluck(:tag)).to_set)
    end
  end

  def destructively_update_tags!(tags)
    self.transaction do
      self.tags = tags.map do |tag_s|
        Tag.find_or_create_by!(account_id: self.account_id, tag: tag_s)
      end
    end
  end

  #TODO: this should be in the presenter
  def display_name
    name.blank? ? hostname : name
  end

  def gone_silent?
    if last_heartbeat_at
      last_heartbeat_at < ACTIVE_WINDOW.ago
    else
      true
    end
  end

  def vulnerable?
    bundles_with_vulnerable.any?(&:vulnerable?)
  end

  def patchable?
    bundles.any?(&:patchable?)
  end

  # TODO: abstract for all OS'
  def system_bundle
    self.bundles.where(:platform => Platforms::OPERATING_SYSTEMS).first
  end

  def platform_release
    PlatformRelease.validate(distro, release)
  end
end
