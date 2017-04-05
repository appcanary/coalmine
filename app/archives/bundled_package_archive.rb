# == Schema Information
#
# Table name: bundled_package_archives
#
#  id                 :integer          not null, primary key
#  bundled_package_id :integer          not null
#  bundle_id          :integer          not null
#  package_id         :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  valid_at           :datetime         not null
#  expired_at         :datetime         not null
#
# Indexes
#
#  idx_bundled_package_id_ar                     (bundled_package_id)
#  index_bundled_package_archives_on_bundle_id   (bundle_id)
#  index_bundled_package_archives_on_expired_at  (expired_at)
#  index_bundled_package_archives_on_package_id  (package_id)
#  index_bundled_package_archives_on_valid_at    (valid_at)
#

# TODO: enforce uniqueness constraint

class BundledPackageArchive < ActiveRecord::Base
  belongs_to :bundled_package
  belongs_to :package
  belongs_to :bundle

  ARCHIVED_COL = self.table_name.gsub("archives", "id")
  ARCHIVED_SELECT = self.columns.reduce([]) { |list, col|
    if col.name == "id"
      list
    elsif col.name == ARCHIVED_COL
      list << "#{self.table_name}.#{col.name} as id"
    else
      list << "#{self.table_name}.#{col.name}"
    end
  }.join(", ")

  scope :select_as_archived, -> { 
    select(ARCHIVED_SELECT)
  }

  scope :select_log_joins_vulns, -> {
    select('"bundled_package_archives".bundle_id, 
           "bundled_package_archives".package_id, 
           "bundled_package_archives".bundled_package_id,
           "bundled_package_archives".expired_at occurred_at,
           "vulnerable_packages".id vulnerable_package_id, 
           "vulnerable_packages".vulnerable_dependency_id vulnerable_dependency_id, 
           "vulnerable_packages".vulnerability_id').
           joins('INNER JOIN "vulnerable_packages" ON
            "vulnerable_packages".package_id = "bundled_package_archives".package_id')

  }

  # don't give me vulns that happened AFTER the package stopped
  # being in my system
  scope :select_valid_log_joins_vulns, -> {
    select_log_joins_vulns.where('"vulnerable_packages".valid_at < "bundled_package_archives".expired_at')
  }

end
