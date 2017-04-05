class ChangeDefaultForMailPrefs < ActiveRecord::Migration
  def up
    change_column_default :users, :pref_email_frequency, PrefOpt::EMAIL_FREQ_DAILY_WHEN_VULN
  end
  def down
    change_column_default :users, :pref_email_frequency, PrefOpt::EMAIL_FREQ_FIRE
  end
end
