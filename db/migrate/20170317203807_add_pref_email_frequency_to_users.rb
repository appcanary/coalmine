class AddPrefEmailFrequencyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pref_email_frequency, :string, :default => PrefOpt::EMAIL_FREQ_DAILY, :null => false
  end
end
