class CesaDescriptionImporter
  def self.import_descriptions
    Advisory.from_rhsa.unprocessed.find_each do |rhsa|
      rhsa.transaction do
        cesa = Advisory.from_cesa.
                 find_by("reference_ids @> ARRAY[?]::varchar[]", [rhsa.identifier])

        unless cesa.nil?
          # port over description
          cesa.description = rhsa.description
          # port over any CVEs
          cesa.reference_ids = (cesa.reference_ids + rhsa.reference_ids).uniq
          cesa.save!

          cesa.advisory_import_state.update_attributes!(processed: false)

          # Reusing the `processed` flag for now because this usage is disjoint
          # with usage by the VulnerabilityImporter. If at some point we start
          # doing multi-step processing we should extract distinct flags for
          # different processing steps.
          rhsa.advisory_import_state.update_attributes!(processed: true)
        end
      end
    end
  end
end
