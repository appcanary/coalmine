# defines two constants, and a method/scope
# 1. ARCHIVED_COL, which is the name of the primary key in the table that is 
#    being archived (aka archivee), ie.  "bundle_archives --> bundle_id"
# 2. ARCHIVED_SELECT, which is a sql select fragment that remaps the archive 
#    table columns to match the archivee's columns
# 3. select_as_archived, which just maps on ARCHIVED_SELECT
#
# Purpose of this is to provide stable interface for point-in-time queries
# across "current"/archivee and archive tables. See module ArchiveBehaviour 


module ArchiveTableBehaviour
  def self.extended(klass)
    klass.const_set(:ARCHIVED_COL, klass.table_name.gsub("archives", "id"))

    select_fields =  klass.columns.reduce([]) { |list, col|
      if col.name == "id"
        list
      elsif col.name == klass::ARCHIVED_COL
        list << "#{klass.table_name}.#{col.name} as id"
      else
        list << "#{klass.table_name}.#{col.name}"
      end
    }.join(", ")

    klass.const_set(:ARCHIVED_SELECT, select_fields)
  end

  def select_as_archived
    select(self::ARCHIVED_SELECT)
  end
end
