class ArchiveMigrator
  class TableBuilder
    attr_accessor :arguments
    def initialize
      self.arguments = []
    end

    def add_argument(name, *args)
      self.arguments.insert(0, [name, args])
    end

    def method_missing(name, *args, &block)
      self.arguments << [name, args]
    end

    def columns
      arguments.map { |type, args|
        if type == :references
          "#{args.first}_id"
        elsif type == :timestamps
          ["created_at","updated_at"]
        else
          args.first.to_s
        end
      }.flatten
    end

    # good christ lord our saviour
    # this hack is necessary because:
    # AR::Migration#create_table, t.datetime :name, HASH_HERE
    # will modify in place the HASH_HERE
    # therefore making it impossible to share one TBuilder
    # instanced between different create_table calls
    #
    # Ruby does not natively support a 'deep clone';
    # dup and clone will return shallow copies that point
    # to the same instance of the @arguments array
    def deep_clone
      Marshal.load(Marshal.dump(self))
    end
  end


  attr_accessor :migration
  def initialize(migration)
    self.migration = migration
  end

  def create_table(table_name)
    singular_table_name = table_name.to_s.singularize.to_sym
    archive_table_name = "#{singular_table_name}_archives"
    table_builder = TableBuilder.new

    # collect schema from migration
    yield table_builder
    build_first_table(table_name, table_builder.deep_clone)

    # the archive table needs to refer back to the orig table
    arch_table_builder = table_builder.deep_clone
    arch_table_builder.add_argument(:references, singular_table_name, index: true, null: false)

    build_archive_table(archive_table_name, singular_table_name, arch_table_builder.deep_clone)

    build_trigger(table_name, archive_table_name, arch_table_builder, table_builder)
  end

  def build_first_table(table_name, table_builder)
    # output what we received
    migration.create_table table_name do |t|
      table_builder.arguments.each do |type, args|
        t.send(type, *args.clone)
      end

      # but add our archive columns
      t.datetime :valid_at, null: false, index: true
      t.datetime :expired_at, null: false, index: true, default: 'infinity'
    end

    # ya can't a column value default to a function output using AR::Migration
    # for Reasons, so let's alter it using SQL
    migration.execute "ALTER TABLE #{table_name} ALTER COLUMN valid_at SET DEFAULT CURRENT_TIMESTAMP"

  end

  def build_archive_table(archive_table_name, singular_table_name, table_builder)
    # now we recreate our schema above, but into an _archives table

    migration.create_table archive_table_name.to_sym do |t|

      # dupe the schema we received above
      table_builder.arguments.each do |type, args|
        new_args = filter_fks(args)
        t.send(type, *new_args)
      end
      t.datetime :valid_at, null: false, index: true
      t.datetime :expired_at, null: false, index:true
    end
  end

  def build_trigger(table_name, archive_table_name, arch_table_builder, orig_table_builder)
    orig_table_cols = orig_table_builder.columns.map{|s| "OLD."+s}.join(", ")
    arch_table_cols = arch_table_builder.columns.join(", ")

    fn_name = "archive_#{table_name}"

    trigger_fn_sql = 
      "CREATE FUNCTION #{fn_name}() RETURNS TRIGGER AS $$
       BEGIN
         INSERT INTO #{archive_table_name}(#{arch_table_cols}, valid_at, expired_at) VALUES
           (OLD.id, #{orig_table_cols}, OLD.valid_at, CURRENT_TIMESTAMP);
         RETURN OLD;
       END;
       $$ language plpgsql;"
 
    trigger_sql = 
    "CREATE TRIGGER trigger_#{archive_table_name}
     AFTER UPDATE OR DELETE
     ON #{table_name}
     FOR EACH ROW
     EXECUTE PROCEDURE #{fn_name}()"

    migration.execute trigger_fn_sql
    migration.execute trigger_sql
  end

  # this is an archive table. We can't have FK constraints,
  # since it's possible their links might break. Gotta filter
  # those out.

  def filter_fks(args)
    args.map { |rg|
      if rg.is_a? Hash
        new_rg = rg.dup
        new_rg.delete(:foreign_key)
        new_rg
      else
        rg
      end
    }
  end
end
