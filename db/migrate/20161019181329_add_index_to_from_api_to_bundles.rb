class AddIndexToFromApiToBundles < ActiveRecord::Migration
  def change
    add_index :bundles, :from_api
  end
end
