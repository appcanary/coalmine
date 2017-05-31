class CreatePartialIndexOnVulnerableDependencies < ActiveRecord::Migration
  def change
    add_index :vulnerable_dependencies, :id, unique: true, where: "vulnerable_dependencies.affected_versions != '{}'
                     OR NOT (vulnerable_dependencies.patched_versions = '{}'
                          AND vulnerable_dependencies.unaffected_versions = '{}')"
  end
end
