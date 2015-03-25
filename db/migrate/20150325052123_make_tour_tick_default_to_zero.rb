class MakeTourTickDefaultToZero < ActiveRecord::Migration
  def change
    change_column :users, :tour_tick, :integer, :default => 0
  end
end
