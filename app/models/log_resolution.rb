class LogResolution < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  belongs_to :package
  belongs_to :vulnerability
  belongs_to :vulnerable_dependency

  scope :filter_query_for, -> (query, account_id) {
    primary_key = query.klass.resolution_log_primary_key
    sane_account_id = sanitize(account_id)

    merge_scope = joins("LEFT JOIN log_resolutions ON
      log_resolutions.vulnerable_dependency_id = vulnerable_dependencies.id AND
      log_resolutions.package_id = #{primary_key} AND
      log_resolutions.account_id = #{sane_account_id}").
    where("log_resolutions.id is null")

    query.merge(merge_scope)
  }

  def self.resolve!(user, pkg, vuln_dep, note = nil)
    self.create!(account: user.account, 
                user: user,
                package: pkg,
                vulnerability: vuln_dep.vulnerability,
                vulnerable_dependency: vuln_dep,
                note: note)
  end

  def self.resolve_package!(user, vuln_pkg, note = nil)
    if note.blank?
      note = nil
    end

    self.transaction do
      vuln_pkg.vulnerable_dependencies.each do |vd|
        self.resolve!(user, vuln_pkg, vd, note)
      end
    end
  end

  def self.delete_with_package!(user, package_id)
    self.where(account_id: user.account_id, package_id: package_id).delete_all
  end
end
