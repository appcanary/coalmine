# skeleton for all importers.
class AdvisoryImporter
  def import!
    update_local_store!
    raw_advisories = fetch_advisories
    all_advisories = raw_advisories.lazy.flat_map { |ra| parse(ra) }
    process_advisories(all_advisories)
  end

  def fetch_advisories
    raise "Importers *must* implement fetch_advisories"
  end

  def parse(ra)
    raise "Importers *must* implement parse(ra)"
  end

  def update_local_store!
    # not everyone needs to do this.
    # benefit of breaking this out
    # is so we can test these classes
    # more readily.
  end

  def process_advisories(all_advisories)
    all_advisories.each do |new_adv|
      old_adv = Advisory.most_recent_advisory_for(new_adv.identifier, self.class::SOURCE).first

      if old_adv.nil?
        # oh look, a new advisory!
        created_adv = Advisory.create!(new_adv.to_advisory_attributes)

      else
        if has_changed?(old_adv, new_adv)

          new_attr = new_adv.to_advisory_attributes

          Advisory.transaction do
            old_adv.processed_flag = false
            old_adv.update_attributes!(new_attr)
          end
        end
      end
    end
  end

  def has_changed?(old_adv, new_adv)
    new_attributes = new_adv.to_advisory_attributes
    # source_text gets serialized in weird ways
    new_attributes = new_attributes.except("source_text")

    # filter out stuff like id, created_at
    old_attributes = old_adv.attributes.slice(*new_adv.relevant_keys)

    old_attributes != new_attributes
  end

end
