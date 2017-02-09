class AddArgsToServerProcesses < ActiveRecord::Migration
  def change
    add_column :server_processes, :args, :string
  end
end
