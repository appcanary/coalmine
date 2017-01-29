class AddNeedsTriageToAdvisory < ActiveRecord::Migration
  def change
    add_column :advisories, :needs_triage, :jsonb, :default => [], :null => false
    add_column :advisories, :package_names, :string, :array => true, :default => [], :null => false
    add_column :advisory_archives, :needs_triage, :jsonb, :default => [], :null => false
    add_column :advisory_archives, :package_names, :string, :array => true, :default => [], :null => false
  end
end
