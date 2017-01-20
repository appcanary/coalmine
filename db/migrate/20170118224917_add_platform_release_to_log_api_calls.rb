class AddPlatformReleaseToLogApiCalls < ActiveRecord::Migration
  def change
    add_column :log_api_calls, :platform, :string
    add_column :log_api_calls, :release, :string
  end
end
