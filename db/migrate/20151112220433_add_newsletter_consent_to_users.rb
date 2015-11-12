class AddNewsletterConsentToUsers < ActiveRecord::Migration
  def change
    add_column :users, :newsletter_consent, :boolean, :default => true, :null => false
  end
end
