class AddAccountIdToTag < ActiveRecord::Migration
  def change
    # include a default just in case this migration gets run separately
    add_reference :tags, :account, foreign_key: true, null: false, default: Account.first.id
    add_index :tags, [:account_id, :tag], unique: true
  end
end
