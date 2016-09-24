class CopyOverAgentToken < ActiveRecord::Migration
  def change
    add_column :users, :agent_token, :string
    if User.new.respond_to?(:api_info)
      User.find_each do |u|
        begin
          u.update_column(:agent_token, u.agent_token)
        rescue CanaryClient::UnauthorizedError
          # used to survive errors in dev mode
        end
      end
    end
  end
end
