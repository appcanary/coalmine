class LogResolution < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  belongs_to :vulnerability
  belongs_to :vulnerable_dependency

  scope :filter_for, -> (account_id) {
    sane_account_id = sanitize(account_id)

    joins("LEFT JOIN log_resolutions ON
      log_resolutions.vulnerable_dependency_id = vulnerable_dependencies.id AND
      log_resolutions.account_id = #{sane_account_id}").
    where("log_resolutions.id is null")

  }

  def self.resolve!(user, vuln_dep, note = nil)
    self.create!(account: user.account, 
                user: user,
                vulnerability: vuln_dep.vulnerability,
                vulnerable_dependency: vuln_dep,
                note: note)
  end

  def self.resolve_package!(user, vuln_pkg, note = nil)
    self.transaction do
      vuln_pkg.vulnerable_dependencies.each do |vd|
        self.resolve!(user, vd, note)
      end
    end
  end
end
