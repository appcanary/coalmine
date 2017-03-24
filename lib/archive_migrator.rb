# this class wraps ActiveRecord migrations and spits out
# corresponding database archive tables, and their corresponding
# postgres triggers
class ArchiveMigrator

  # this class acts as a proxy between our code and the 
  # normal rails migration code; it fakes accepting the same
  # methods & arguments, for the most part, and lets us transform
  # them prior to passing it along to the Migration layer.
  class TableBuilder
    attr_accessor :arguments, :is_archive, :initial_columns
    UNSUPPORTED_TRANSFORMATIONS = [:rename_index, :change, :change_default, 
                                   :rename, :belongs_to, :remove, :remove_references, 
                                   :remove_belongs_to, :remove_index, :remove_timestamps]

    def initialize(table_name = nil, opts = {})
      if table_name
        self.initial_columns = table_to_model(table_name).column_names
      else
        self.initial_columns = []
      end

      # could do this by reading the table name but I think it's dirty
      if opts[:archive]
        self.is_archive = true
      end

      self.arguments = []
    end

    def add_argument(name, *args)
      self.arguments.insert(0, [name, args])
    end

    def method_missing(name, *args, &block)
      #TODO this should use the list of acceptable methods below instead of accepting everything
      self.arguments << [name, args]
    end

    def send_arguments(t)
      if self.is_archive
        self.arguments.each do |type, args|
          new_args = filter_args_for_archive(args)
          t.send(type, *new_args)
        end
      else
        self.arguments.each do |type, args|
          t.send(type, *args)
        end
      end
    end

    # Comment below is from ActiveRecord::ConnectionAdapters::TableDefinition
    # (see UNSUPPORTED_TRANSFORMATIONS above)
    # -----
    # Represents an SQL table in an abstract way for updating a table.
    # Also see TableDefinition and SchemaStatements#create_table
    #
    # Available transformations are:
    #
    #   change_table :table do |t|
    #     t.column
    #     t.index
    #     t.rename_index
    #     t.timestamps
    #     t.change
    #     t.change_default
    #     t.rename
    #     t.references
    #     t.belongs_to
    #     t.string
    #     t.text
    #     t.integer
    #     t.float
    #     t.decimal
    #     t.datetime
    #     t.timestamp
    #     t.time
    #     t.date
    #     t.binary
    #     t.boolean
    #     t.remove
    #     t.remove_references
    #     t.remove_belongs_to
    #     t.remove_index
    #     t.remove_timestamps
    #   end
    #

    def columns
      new_columns = arguments.map { |type, args|

        if UNSUPPORTED_TRANSFORMATIONS.include?(type)
          raise ActiveRecord::MigrationError.new("Archive doesn't support transformation #{type}")

        elsif type == :references
          "#{args.first}_id"

        elsif type == :timestamps
          ["created_at","updated_at"]

        else
          args.first.to_s
        end

      }.flatten
      filter_columns(initial_columns + new_columns)
    end

    # Don't return valid_at and expired_at and make sure we uniqify just in case
    def filter_columns(columns)
      columns = columns.uniq - ["id", "expired_at", "valid_at"]
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

    def table_to_model(table_name)
      # Raises an error if the class doesn't exist
      # TODO: what if the model isn't the same name as the table?
      table_name.to_s.classify.constantize
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


  attr_accessor :migration, :table_name, :singular_table_name, :archive_table_name
  def initialize(migration)
    self.migration = migration
  end

  def create_table(table_name, opt = {})
    compute_table_names(table_name)

    table_builder = TableBuilder.new

    # collect schema from migration
    yield table_builder

    # use this schema to create the archive table
    archive_table_builder = build_archive_schema(table_builder, self.singular_table_name)

    construct_table!(table_name, table_builder, opt)
    construct_table!(archive_table_name, archive_table_builder, opt)

    construct_triggers!(table_name, self.archive_table_name, archive_table_builder, table_builder)
  end

  def change_table(table_name, opt = {})
    compute_table_names(table_name)

    table_builder = TableBuilder.new(table_name)
    archive_table_builder = TableBuilder.new(archive_table_name, archive: true)

    yield table_builder
    # execute the same commands on the archive table
    yield archive_table_builder

    alter_table!(table_name, table_builder, opt)
    alter_table!(self.archive_table_name, archive_table_builder, opt)
    construct_triggers!(self.table_name, self.archive_table_name, archive_table_builder, table_builder)
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
      builder.send_arguments(t)
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

      migration.reversible do |dir| 
        dir.up do
          migration.execute "ALTER TABLE #{table_name} ALTER COLUMN valid_at SET DEFAULT CURRENT_TIMESTAMP"
        end
        dir.down do
          warn "Archive migrations don't reverse the triggers and functions properly! You have to clean this up manually and KNOW WHAT YOU'RE DOING"
        end
      end
    end
  end

  def alter_table!(table_name, table_builder, opt)
    builder = table_builder.deep_clone

    self.migration.change_table(table_name, opt) do |t|
      builder.send_arguments(t)
    end
  end

  def construct_triggers!(table_name, archive_table_name, arch_table_builder, orig_table_builder)
    archive_fn_name = "archive_#{table_name}"
    update_fn_name = "update_#{table_name}_valid_at"

    orig_table_cols = orig_table_builder.columns.map{|s| "OLD."+s}.join(", ")
    arch_table_cols = arch_table_builder.columns.join(", ")

    # note that the archive trigger is called "trigger_#{archive_table_name}".
    # I'd prefer it to be called "trigger_#{archive_fn_name}" to be consitent
    # with the update trigger, but we'd have to drop the old trigger on
    # migration so we'll keep the old one
    trigger_sql =
      "DO
       $$BEGIN
         DROP TRIGGER IF EXISTS trigger_#{archive_table_name} ON #{table_name};
         CREATE TRIGGER trigger_#{archive_table_name}
         AFTER UPDATE OR DELETE
         ON #{table_name}
         FOR EACH ROW
         EXECUTE PROCEDURE #{archive_fn_name}();

         DROP TRIGGER IF EXISTS trigger_#{update_fn_name} ON #{table_name};
         CREATE TRIGGER trigger_#{update_fn_name}
         BEFORE UPDATE
         ON #{table_name}
         FOR EACH ROW
         EXECUTE PROCEDURE #{update_fn_name}();
      END$$"

    # the magic works like this:
    # every time a row is updated or deleted, it gets copied into an archive table
    # and its expired_at value is replaced with the current time.
    archive_fn_sql =
      "CREATE OR REPLACE FUNCTION #{archive_fn_name}() RETURNS TRIGGER AS $$
       BEGIN
         INSERT INTO #{archive_table_name}(#{arch_table_cols}, valid_at, expired_at) VALUES
           (OLD.id, #{orig_table_cols}, OLD.valid_at, now());
         RETURN OLD;
       END;
       $$ language plpgsql;"

    # similarly, whenever a row is updated, we must also update the valid_at field:
    update_fn_sql =
      "CREATE OR REPLACE FUNCTION #{update_fn_name}() RETURNS TRIGGER AS $$
       BEGIN
         NEW.valid_at = now();
         RETURN NEW;
       END;
       $$ language plpgsql;"

    migration.reversible do |dir|
      dir.up do
        migration.execute archive_fn_sql
        migration.execute update_fn_sql
        migration.execute trigger_sql
      end
      dir.down do
        warn "Archive migrations don't reverse the triggers and functions properly! You have to clean this up manually and KNOW WHAT YOU'RE DOING"
      end
    end
  end

  def compute_table_names(table_name)
    self.table_name = table_name
    self.singular_table_name = table_name.to_s.singularize.to_sym
    self.archive_table_name = "#{singular_table_name}_archives".to_sym
  end
end
