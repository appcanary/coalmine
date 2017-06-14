class AddProcessedCountToAdvisoryImportState < ActiveRecord::Migration
  def change
    add_column :advisory_import_states, :processed_count, :integer, default: 0
  end
end
