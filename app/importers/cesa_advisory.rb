# TODO: what about related urls?
class CesaAdvisory < AdvisoryPresenter.new(:cesa_id, :issue_date, :synopsis, 
                                           :severity, :os_arches, :os_releases, 
                                           :packages)

  def identifier
    @gen_cesa_id ||= cesa_id.gsub("--", ":")
  end

  def package_platform
    Platforms::CentOS
  end

  def source
    CesaImporter::SOURCE
  end

  generate :patched do
    packages.map { |p|
      {"filename" => p}
    }
  end

  # TODO: needs to change?
  generate :affected do
    os_arches.map do |arch|
      os_releases.map do |rel|
        {"arch" => arch, "release" => rel}
      end
    end.flatten
  end

  generate :criticality do
    case severity
    when "Critical"
      "critical"
    when "Important"
      "high"
    when "Moderate"
      "medium"
    when "Low"
      "low"
    else
      "unknown"
    end
  end

  generate :title do
    synopsis
  end

 
  generate :reported_at do
    issue_date
  end

end
