class AddTourTickToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tour_tick, :int, :default => 1
  end
end
