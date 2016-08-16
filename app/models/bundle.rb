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
#  index_bundles_on_valid_at                                 (valid_at)
#

class Bundle < ActiveRecord::Base
  belongs_to :account
  belongs_to :agent_server
  has_many :bundled_packages
  has_many :packages, :through => :bundled_packages
  has_many :log_bundle_vulnerabilities

  validates :account, presence: true

  scope :belonging_to, -> (user) {
    where(:account_id => user.account_id)
  }

  scope :via_agent, -> {
    where("agent_server_id is not null")
  }

  scope :via_api, -> { where("agent_server_id is null") }

  # TODO: default bundle name?

  def vulnerable?
    self.vulnerable_packages.any?
  end

  def display_name
    name.blank? ? path : name
  end

  # TODO convert to has many?
  def vulnerable_packages
    VulnerablePackage.where('"bundled_packages".bundle_id = ?', self.id).joins('inner join bundled_packages on "bundled_packages".package_id ="vulnerable_packages".package_id')
  end
end
