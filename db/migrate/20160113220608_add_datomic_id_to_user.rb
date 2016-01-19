class AddDatomicIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :datomic_id, :bigint
  end
end
