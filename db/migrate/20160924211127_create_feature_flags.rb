class CreateFeatureFlags < ActiveRecord::Migration
  def change
    enable_extension "hstore"
    create_table :feature_flags do |t|
      t.hstore :data, index: true

      t.timestamps null: false
    end
  end
end
