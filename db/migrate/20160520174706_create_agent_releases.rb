class CreateAgentReleases < ActiveRecord::Migration
  def change
    create_table :agent_releases do |t|
      t.string :version, index: true

      t.timestamps null: false
    end
  end
end
