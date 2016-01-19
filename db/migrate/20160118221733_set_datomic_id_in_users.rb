class SetDatomicIdInUsers < ActiveRecord::Migration
  def change
    User.find_each do |user|
      user.update_attribute(:datomic_id, user.api_info["id"])
    end
  end
end
