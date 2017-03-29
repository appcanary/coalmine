class AddAffectedVersionsToVulnerableDependencies < ActiveRecord::Migration
  def change
    add_column :vulnerable_dependencies, :affected_versions, :text,
               array: true, default: [], null: false
  end
end
