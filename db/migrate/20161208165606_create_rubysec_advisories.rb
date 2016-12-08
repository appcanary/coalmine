class CreateRubysecAdvisories < ActiveRecord::Migration
  def change
    create_table :rubysec_advisories do |t|
      t.string :ident, index: true
      t.string :gem
      t.string :framework
      t.string :platform
      t.string :cve
      t.string :url
      t.string :title
      t.date :date
      t.text :description
      t.string :cvss_v2
      t.string :cvss_v3
      t.string :unaffected_versions, array: true, default: []
      t.string :patched_versions, array: true, default: []
      t.text :related
      t.string :submitter_email

      t.timestamps null: false
    end
  end
end
