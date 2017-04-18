class AddAffectedVersionsToVulnerableDependencies < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).change_table :vulnerable_dependencies do |t|
      t.string :affected_versions, :text, array: true, default: [], null: false
    end
  end
end
