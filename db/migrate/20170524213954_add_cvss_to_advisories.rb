class AddCvssToAdvisories < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).change_table :advisories do |t|
      t.string :cvss
    end
  end
end
