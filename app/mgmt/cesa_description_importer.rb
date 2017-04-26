class CesaDescriptionImporter
  include ResultObject

  attr_reader :since

  def initialize(since = nil)
    @since = since || 2.hours.ago
  end

  def import_descriptions
    errors = []

    Advisory.from_rhsa.where("updated_at > ?", since).each do |advisory|
      begin
        cesa = Advisory.from_cesa.
                 find_by("reference_ids @> ARRAY[?]::varchar[]", [advisory.identifier])
        unless cesa.nil?
          cesa.description = advisory.description
          cesa.save!
        end
      rescue => e
        Rails.logger.warn(e)
        errors << e
      end
    end

    Result.new(true, errors.empty? ? nil : errors)
  end

  def self.import_all_descriptions
    self.new(Time.at(0)).import_descriptions
  end
end
