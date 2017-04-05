class AddPackagesToVulnerabilities < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).change_table :vulnerabilities do |t|
      t.string :package_names, :array => true, :default => [], :null => false
    end
  end
end
