class CreateBundleProcessedState < ActiveRecord::Migration
  def change
    create_table :bundle_processed_states do |t|
      t.references :bundle, index: true, foreign_key_key: true
      t.boolean :processed, default: false, null: false

      t.timestamps null: false
    end
    Bundle.find_each do |bundle|
      bundle.create_bundle_processed_state
    end
  end
end

