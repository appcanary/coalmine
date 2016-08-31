  # TODO: what about related urls?
class CesaAdvisory < Advisory.new(:cesa_id, :issue_date, :synopsis, 
                                  :severity, :os_arches, :os_releases, 
                                  :packages)
   
  def identifier
      generate_cesa_id
    end

    def generate_patched
      packages.map { |p|
        {"filename" => p}
      }
    end

    def generate_affected
      os_arches.map do |arch|
        os_releases.map do |rel|
          {"arch" => arch, "release" => rel}
        end
      end.flatten
    end

    def generate_criticality
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

    def generate_cesa_id
      @gen_cesa_id ||= cesa_id.gsub("--", ":")
    end

    def generate_title
      synopsis
    end

    def package_platform
      Platforms::CentOS
    end

    def generate_reported_at
      issue_date
    end

    def source
      CesaImporter::SOURCE
    end

    def advisory_keys
      ["identifier", "package_platform", "patched", "affected", "criticality", "reported_at", "title", "cesa_id", "source"]
    end
end
