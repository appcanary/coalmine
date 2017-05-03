class CesaDescriptionImporter
  def self.import_descriptions
    errors = []

    Advisory.from_rhsa.unprocessed.find_each do |rhsa|
      rhsa.transaction do
        cesa = Advisory.from_cesa.
                 find_by("reference_ids @> ARRAY[?]::varchar[]", [rhsa.identifier])

        unless cesa.nil?
          cesa.description = rhsa.description
          cesa.save!

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
