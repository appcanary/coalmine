class AddEmailConsentTogglesToUser < ActiveRecord::Migration
  def change
    add_column :users, :marketing_email_consent, :boolean, :null => false, :default => true
    add_column :users, :daily_email_consent, :boolean, :null => false, :default => false
    rename_column :users, :newsletter_consent, :newsletter_email_consent
  end
end
