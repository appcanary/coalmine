class TruncateVulnArchiveAndAdvisoryImportStates < ActiveRecord::Migration
  def change
    VulnerabilityArchive.where("expired_at >= ?", Date.new(2016,12,24)).delete_all
    AdvisoryImportState.delete_all

    change_column_null :advisory_import_states, :advisory_id, false
  end
end
