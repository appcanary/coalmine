class CreateVulnerabilities < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).create_table :vulnerabilities do |t|
      t.string :platform, null: false, index: true
      t.string :title
      t.text :description
      t.string :criticality

      t.string :reference_ids, array: true, :default => [], null: false
      t.string :osvdb_id
      t.string :usn_id
      t.string :dsa_id
      t.string :rhsa_id
      t.string :cesa_id
      t.string :source

      t.datetime :reported_at

      t.timestamps null: false
    end


    ArchiveMigrator.new(self).create_table :advisory_vulnerabilities do |t|
      t.references :advisory, null: false, index: {name: "idx_adv_vuln_adv"}
      t.references :vulnerability, null: false, index: {name: "idx_adv_vuln_vuln"}
    end

  end
end
