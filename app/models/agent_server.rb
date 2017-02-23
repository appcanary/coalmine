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
  ACTIVE_WINDOW = 2.hours
  belongs_to :account
  validates :account, :presence => true

  belongs_to :agent_release
  has_many :bundles, :dependent => :destroy
  has_many :heartbeats, :class_name => AgentHeartbeat
  has_many :received_files, :class_name => AgentReceivedFile
  has_many :accepted_files, :class_name => AgentAcceptedFile
  has_many :server_tags, :dependent => :destroy
  has_many :tags, :through => :server_tags

  has_one :last_heartbeat, -> { order(created_at: :desc) }, :class_name => AgentHeartbeat, :foreign_key => :agent_server_id

  scope :belonging_to, -> (user) {
    where(:account_id => user.account_id)
  }

  scope :active, -> {
    joins(:heartbeats).where('"agent_heartbeats".created_at > ?', ACTIVE_WINDOW.ago).distinct("agent_servers.id")
  }


  # TODO: figure out inactive scope
  
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

  def update_tags!(tags)
    self.transaction do
      new_tags = tags - self.tags.pluck(:tag)
      self.tags << new_tags.map { |tag_s| Tag.find_or_create_by!(tag: tag_s) }
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
    bundles.any?(&:vulnerable?)
  end

  def patchable?
    bundles.any?(&:patchable?)
  end

  # TODO: abstract for all OS'
  def system_bundle
    self.bundles.where(:platform => Platforms::OPERATING_SYSTEMS).first
  end
end
