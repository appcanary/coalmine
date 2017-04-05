class AddNeedsTriageToAdvisory < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).change_table :advisories do |t|
      t.jsonb :needs_triage, :default => [], :null => false
      t.string :package_names, :array => true, :default => [], :null => false
    end
  end
end
