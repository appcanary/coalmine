class UpdateTriggers < ActiveRecord::Migration
  def up
    # since we never had the valid at trigger before, our valid ats aren't set correctly on tables that allow you to edit. we need to cheat and set all the archives valid_ats to be the updated_at

    execute "UPDATE advisories set valid_at = updated_at"
    execute "UPDATE advisory_archives set valid_at = updated_at"
    execute "UPDATE agent_servers set valid_at = updated_at"
    execute "UPDATE agent_server_archives set valid_at = updated_at"
    execute "UPDATE bundles set valid_at = updated_at"
    execute "UPDATE bundle_archives set valid_at = updated_at"
    execute "UPDATE vulnerabilities set valid_at = updated_at"
    execute "UPDATE vulnerability_archives set valid_at = updated_at"

    archive_tables = ActiveRecord::Base.connection.tables.select { |t| t.ends_with? "archives" }
    tables = archive_tables.map { |s| s.gsub(/_archives/,"").pluralize.to_sym }
    tables.each do |tbl|
      ArchiveMigrator.new(self).change_table tbl do |t|
        # nop migration will update the triggers
      end
    end
  end
  def down
    #nop
  end
end
