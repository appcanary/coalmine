class UsnAdapter < AdvisoryAdapter.new(:cves, :id, :isummary, :action, :summary, :timestamp, :title, :releases, :description)
  def identifier
    "USN-" + id
  end

  def source
    UsnImporter::SOURCE
  end

  def platform
    UsnImporter::PLATFORM
  end

  generate :reference_ids do
    cves || []
  end

  generate :title do
    title
  end

  generate :reported_at do
    Time.at(timestamp.to_i).to_datetime.utc
  end

  generate :description do
    # TODO include isummary, summary, and action either here or in another column of the advisory table
    description.force_encoding('UTF-8')
  end
end
