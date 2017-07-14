class AddIndexesForDailySummary < ActiveRecord::Migration
  def change
    add_index :vulnerable_dependencies, [:created_at, :valid_at], where: "(vulnerable_dependencies.patched_versions = '{}'::text[]) AND (vulnerable_dependencies.unaffected_versions = '{}'::text[])", name: "index_vulndeps_on_valid_at_and_created_at_unpatchable"
    add_index :vulnerable_dependencies, [:created_at, :valid_at], where: "((vulnerable_dependencies.affected_versions <> '{}'::character varying[]) OR (vulnerable_dependencies.patched_versions <> '{}'::text[]) OR (vulnerable_dependencies.unaffected_versions <> '{}'::text[]))", name: "index_vulndeps_on_valid_at_and_created_at_patchable"
    add_index :vulnerable_dependencies, [:valid_at], where: "((vulnerable_dependencies.affected_versions <> '{}'::character varying[]) OR (vulnerable_dependencies.patched_versions <> '{}'::text[]) OR (vulnerable_dependencies.unaffected_versions <> '{}'::text[]))", name: "index_vulndeps_on_valid_at_patchable"
    add_index :vulnerable_dependencies, [:valid_at], where: "(vulnerable_dependencies.patched_versions = '{}'::text[]) AND (vulnerable_dependencies.unaffected_versions = '{}'::text[])", name: "index_vulndeps_on_valid_at_unpatchable"
    add_index :log_bundle_vulnerabilities, [:bundle_id, :package_id, :bundled_package_id, :vulnerability_id, :vulnerable_dependency_id, :vulnerable_package_id, :occurred_at], unique: true, name: "index_of_seven_kings_LBV"
    add_index :log_bundle_patches, [:bundle_id, :package_id, :bundled_package_id, :vulnerability_id, :vulnerable_dependency_id, :vulnerable_package_id, :occurred_at], unique: true, name: "index_of_seven_kings_LBP"
    add_index :bundle_archives, [:bundle_id, :expired_at], order: {expired_at: :desc}
    add_index :bundle_archives, [:created_at, :bundle_id, :expired_at], order: {expired_at: :desc, created_at: :desc}, name: "bundle_archives_CBE"
  end
end
