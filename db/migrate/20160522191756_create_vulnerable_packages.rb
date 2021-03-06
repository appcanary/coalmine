class CreateVulnerablePackages < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).create_table :vulnerable_packages do |t|
      t.references :package, index: true, foreign_key: true, null: false
      t.references :vulnerable_dependency, index: true, foreign_key: true, null: false
      t.references :vulnerability, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
