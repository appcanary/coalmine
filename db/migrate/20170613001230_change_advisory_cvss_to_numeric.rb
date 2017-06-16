class ChangeAdvisoryCvssToNumeric < ActiveRecord::Migration
  def change
    ArchiveMigrator.new(self).change_table :advisories do |t|
      reversible do |direction|
        direction.up {t.change :cvss, 'numeric USING CAST(cvss AS numeric)'}
        direction.down {t.change :cvss, :string}
      end
      t.index  [:cvss], :order => 'DESC NULLS LAST'
    end
  end
end
