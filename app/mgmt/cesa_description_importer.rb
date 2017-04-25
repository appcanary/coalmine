class CesaDescriptionImporter
  attr_reader :since

  def initialize(since = nil)
    @since = since || 2.hours.ago
  end

  def import_descriptions
    Advisory.from_rhsa.where("updated_at > ?", since).each do |advisory|
      begin
        cesa = Advisory.from_cesa.
                 find_by("reference_ids @> ARRAY[?]::varchar[]", advisory.identifier)
        cesa.description = advisory.description
        cesa.save!
      rescue => e
        logger.warn(e)
      end
    end
  end

  def self.import_all_descriptions
    self.new(Time.at(0)).import_descriptions
  end
end
