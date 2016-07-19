class ArchiveMigrator
  class TableBuilder
    attr_accessor :arguments, :is_archive
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

  def create_table(table_name, opt = {})
    singular_table_name = table_name.to_s.singularize.to_sym
    archive_table_name = "#{singular_table_name}_archives".to_sym
    
    table_builder = TableBuilder.new

    # collect schema from migration
    yield table_builder

    # we now know what the table will look like.
    archive_table_builder = build_archive_schema(table_builder, singular_table_name)

    construct_table!(table_name, table_builder, opt)
    construct_table!(archive_table_name, archive_table_builder, opt)

    construct_trigger!(table_name, archive_table_name, archive_table_builder, table_builder)
  end

  def build_archive_schema(tb, singular_table_name)
    # the archive table needs to refer back to the orig table
    arch_table_builder = tb.deep_clone
    # custom index name cos some auto table names overflow the 64 char limit
    arch_table_builder.add_argument(:references, singular_table_name, index: {name: "idx_#{singular_table_name}_id"}, null: false)
    arch_table_builder.is_archive = true
    arch_table_builder
  end

  def construct_table!(table_name, table_builder, opt)
    builder = table_builder.deep_clone

    self.migration.create_table(table_name, opt) do |t|
 
      if builder.is_archive
        builder.arguments.each do |type, args|
          new_args = filter_args_for_archive(args)
          t.send(type, *new_args)
        end

      else
        builder.arguments.each do |type, args|
          t.send(type, *args)
        end
      end

      # --- we've inputted the schema provided
      # from the migration. now we add our archive columns
      t.datetime :valid_at, null: false, index: true

      if builder.is_archive
        t.datetime :expired_at, null: false, index: true
      else
        t.datetime :expired_at, null: false, index: true, default: 'infinity'
      end

    end

    unless builder.is_archive
      # ya can't have column value default to a function output using AR::Migration
      # for Reasons, so let's alter it using SQL
      migration.execute "ALTER TABLE #{table_name} ALTER COLUMN valid_at SET DEFAULT CURRENT_TIMESTAMP"
    end
  end

  def construct_trigger!(table_name, archive_table_name, arch_table_builder, orig_table_builder)
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
  #
  # also sometimes index names are too long, so we need to
  # be able to take custom index names and add our own suffix

  def filter_args_for_archive(args)
    args.map { |rg|
      if rg.is_a? Hash
        new_rg = rg.dup
        new_rg.delete(:foreign_key)
        if (new_rg[:index].is_a? Hash) && new_rg[:index][:name]
          new_rg[:index][:name] = new_rg[:index][:name] + "_ar"
        end
        new_rg
      else
        rg
      end
    }
  end
end
