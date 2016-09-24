class CopyAgentTokenToAccounts < ActiveRecord::Migration
  def change
    User.find_each do |u|
      if u.agent_token.present?
        u.account.update_column(:token, u.agent_token)
      end
    end
  end
end
