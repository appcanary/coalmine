class CreateIsItVulnResults < ActiveRecord::Migration
  def change
    create_table :is_it_vuln_results do |t|
      t.string :ident, null: false
      t.text :result
    
      t.timestamps null: false
      t.index :ident
    end
  end
end
