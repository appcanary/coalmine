class AddBetaSignUpSourceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :beta_signup_source, :string
  end
end
