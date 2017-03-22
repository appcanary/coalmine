class UpdateTriggers < ActiveRecord::Migration
  def change
    archive_tables = ActiveRecord::Base.connection.tables.select { |t| t.ends_with? "archives" }
    tables = archive_tables.map { |s| s.gsub(/_archives/,"").pluralize.to_sym }
    tables.each do |tbl|
      ArchiveMigrator.new(self).change_table tbl do |t|
        # nop migration will update the triggers
      end
    end
  end
end
