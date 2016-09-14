# skeleton for all importers.
class AdvisoryImporter
  def import!
    update_local_store!
    raw_advisories = fetch_advisories
    all_advisories = raw_advisories.map { |ra| parse(ra) }
    process_advisories(all_advisories)
  end

  def update_local_store!
    # not everyone needs to do this.
    # benefit of breaking this out
    # is so we can test these classes
    # more readily.
  end

  def process_advisories(all_advisories)
    all_advisories.each do |adv|
      qadv = Advisory.most_recent_advisory_for(adv.identifier, self.class::SOURCE).first

      if qadv.nil?
        # oh look, a new advisory!
        Advisory.create!(adv.to_advisory_attributes)
      else
        if has_changed?(qadv, adv)
          new_attr = adv.to_advisory_attributes
          new_attr["processed"] = false
          qadv.update_attributes(new_attr)
        end
      end
    end
  end

  def has_changed?(existing_advisory, adv)
    new_attributes = adv.to_advisory_attributes
    relevant_attributes = existing_advisory.attributes.keep_if { |k, _| new_attributes.key?(k) }

    # obviously, move this somewhere else
    relevant_attributes.except("source_text") != new_attributes.except("source_text")
  end

end
