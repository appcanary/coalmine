class UsnReferenceImporter
  def self.import_references
    Advisory.from_usn.unprocessed_or_incomplete.find_each do |usn|
      usn.transaction do
        usn.reference_ids.select { |r| r.start_with?('CVE') }.each do |identifier|
          cve = Advisory.from_ubuntu.find_by(identifier: identifier)

          unless cve.nil? || cve.reference_ids.include?(usn.identifier)
            cve.reference_ids << usn.identifier
            cve.save!

            usn.advisory_import_state.processed_count += 1
            usn.advisory_import_state.save!
          end
        end
      end
    end
  end
end
