class AddIndexesForDailySummary < ActiveRecord::Migration
  def change
    add_index :vulnerable_dependencies, [:created_at, :valid_at], where: "(vulnerable_dependencies.patched_versions = '{}'::text[]) AND (vulnerable_dependencies.unaffected_versions = '{}'::text[])", name: "index_vulndeps_on_valid_at_and_created_at_unpatchable"
    add_index :vulnerable_dependencies, [:created_at, :valid_at], where: "((vulnerable_dependencies.affected_versions <> '{}'::character varying[]) OR (vulnerable_dependencies.patched_versions <> '{}'::text[]) OR (vulnerable_dependencies.unaffected_versions <> '{}'::text[]))", name: "index_vulndeps_on_valid_at_and_created_at_patchable"
  end
end
