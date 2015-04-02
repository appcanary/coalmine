class RemoveTourTickFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :tour_tick
  end
end
