class RemoveFromApi < ActiveRecord::Migration
  def change
    execute "SET session_replication_role = replica;"
    ArchiveMigrator.new(self).change_table :bundles do |t|
      t.remove :from_api
    end
    execute "SET session_replication_role = DEFAULT"
  end
end
