class CreateBundledPackages < ActiveRecord::Migration
  def change
    create_table :bundled_packages do |t|
      t.references :bundle, index: true, foreign_key: true
      t.references :package, index: true, foreign_key: true

      t.timestamps null: false
      t.datetime :valid_at, null: false, index: true
      t.datetime :expired_at, null: false, index: true, default: 'infinity'
    end

    create_table :bundled_package_archives do |t|
      t.references :bundled_package, index: true
      t.references :bundle, index: true
      t.references :package, index: true

      t.timestamps null: false
      t.datetime :valid_at, null: false, index: true
      t.datetime :expired_at, null: false, index:true
    end

    execute "ALTER TABLE bundled_packages ALTER COLUMN valid_at SET DEFAULT CURRENT_TIMESTAMP"

    execute "CREATE FUNCTION archive_bundled_packages() RETURNS TRIGGER AS $$
             BEGIN
               INSERT INTO bundled_package_archives(bundled_package_id, bundle_id, package_id, created_at, updated_at, valid_at, expired_at) VALUES
                 (OLD.id, OLD.bundle_id, OLD.package_id, OLD.created_at, OLD.updated_at, OLD.valid_at, CURRENT_TIMESTAMP);
               RETURN OLD;
             END;
             $$ language plpgsql;"

    execute "CREATE TRIGGER trigger_bundled_package_archive 
             AFTER UPDATE OR DELETE
             ON bundled_packages
             FOR EACH ROW 
             EXECUTE PROCEDURE archive_bundled_packages()"
  end
end
