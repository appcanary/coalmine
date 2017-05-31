# == Schema Information
#
# Table name: log_resolutions
#
#  id                       :integer          not null, primary key
#  account_id               :integer          not null
#  user_id                  :integer          not null
#  package_id               :integer          not null
#  vulnerability_id         :integer          not null
#  vulnerable_dependency_id :integer          not null
#  note                     :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_log_resolutions_on_account_id                (account_id)
#  index_log_resolutions_on_package_id                (package_id)
#  index_log_resolutions_on_user_id                   (user_id)
#  index_log_resolutions_on_vulnerability_id          (vulnerability_id)
#  index_log_resolutions_on_vulnerable_dependency_id  (vulnerable_dependency_id)
#  index_logres_account_vulndeps                      (account_id,package_id,vulnerable_dependency_id) UNIQUE
#

class LogResolution < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  belongs_to :package
  belongs_to :vulnerability
  belongs_to :vulnerable_dependency

  scope :filter_query_for, -> (query, account_id = nil) {
    primary_key = query.klass.resolution_log_primary_key
    if account_id
      sanitized_account_id = sanitize(account_id)
    else
      sanitized_account_id = "bundles.account_id"
    end


    merge_scope = joins("LEFT JOIN log_resolutions ON
      log_resolutions.vulnerable_dependency_id = vulnerable_dependencies.id AND
      log_resolutions.package_id = #{primary_key} AND
      log_resolutions.account_id = #{sanitized_account_id}").
    where("log_resolutions.id is null")

    query.merge(merge_scope)
  }

  validates_uniqueness_of :vulnerable_dependency_id, scope: [:account_id, :package_id]


  def self.resolve(user, pkg, vuln_dep, note = nil)
    self.create(account: user.account, 
                user: user,
                package: pkg,
                vulnerability: vuln_dep.vulnerability,
                vulnerable_dependency: vuln_dep,
                note: note)
  end

  def self.resolve_package(user, vuln_pkg, note = nil)
    if note.blank?
      note = nil
    end

    self.transaction do
      vuln_pkg.vulnerable_dependencies.each do |vd|
        self.resolve(user, vuln_pkg, vd, note)
      end
    end
  end

  def self.delete_with_package(user, package_id)
    self.where(account_id: user.account_id, package_id: package_id).delete_all
  end
end
