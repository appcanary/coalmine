class CreateLogApiCalls < ActiveRecord::Migration
  def change
    create_table :log_api_calls do |t|
      t.references :account
      t.string :action, index: true

      t.timestamps null: false
    end
  end
end
