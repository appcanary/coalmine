class AddPackagesToVulnerabilities < ActiveRecord::Migration
  def change
    add_column :vulnerabilities, :package_names, :string, :array => true, :default => [], :null => false
    add_column :vulnerability_archives, :package_names, :string, :array => true, :default => [], :null => false
  end
end
