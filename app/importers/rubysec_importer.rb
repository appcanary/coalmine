require 'fileutils'
class RubysecImporter
  SOURCE = "rubysec"
  REPO_URL = "https://github.com/rubysec/ruby-advisory-db.git"
  REPO_PATH = "tmp/importer/rubysec"

  # TODO: test, natch
  def import!
    git = GitHandler.new(self.class, REPO_URL, local_path)
    git.fetch_and_update_repo!

    all_advisories = load_advisories
    process_advisories(all_advisories)
  end

  def local_path
    File.join(Rails.root, REPO_PATH)
  end

  
  def load_advisories
    Dir[File.join(local_path, "gems", "/**/**yml")].map do |ymlf|
      RubysecAdvisory.new(ymlf, YAML.load_file(ymlf))
    end
  end

  def process_advisories(all_advisories)
    all_advisories.each do |adv|
      if qadv = QueuedAdvisory.most_recent_advisory_for(adv.identifier, SOURCE).first
        new_attributes = adv.to_advisory_attributes

        if has_changed?(qadv, new_attributes)
          QueuedAdvisory.create!(new_attributes)
        end
        # else. do nothing.
      else
        # oh look, a new advisory!
        QueuedAdvisory.create!(adv.to_advisory_attributes)
      end
    end
  end

  def has_changed?(existing_advisory, new_attributes)
    relevant_attributes = existing_advisory.attributes.keep_if { |k, _| new_attributes.key?(k) }
    
    relevant_attributes != new_attributes
  end

  # TODO: what about related and url?
  class RubysecAdvisory
    ATTR = ['filepath', 'gem', 'cve', 'osvdb', 'url', 'title', 'date', 
      'description', 'cvss_v2', 'cvss_v3', 'patched_versions', 'unaffected_versions', 'related']
    ATTR_LOOKUP = Hash[ ATTR.map { |attr| [attr, true] } ]
    attr_accessor *ATTR.map(&:to_sym)

    def initialize(filepath, hsh)
      self.filepath = filepath
      hsh.each_pair do |k, v|
        if ATTR_LOOKUP[k]
          self.send("#{k}=", v)
        end
      end
    end

    def identifier
      filepath.split("/")[-2..-1].join("/")
    end

    def generate_patched
      if patched_versions
        patched_versions.map do |pv|
          {"constraint" => pv, "name" => gem}
        end
      else
        []
      end
    end

    def generate_unaffected
      if unaffected_versions
        unaffected_versions.map do |pv|
          {"constraint" => pv, "name" => gem}
        end
      else
        []
      end
    end


    def generate_cve_ids
      if cve
        ["CVE-#{cve}"]
      else
        []
      end
    end

    def generate_osvdb_id
      if osvdb
        "OSVDB-#{osvdb}"
      else
        nil
      end
    end

    def cvss_score
      cvss_v2 || cvss_v3
    end

    def generate_criticality
      case cvss_score
      when 0.0..3.3
        "low"
      when 3.3..6.6
        "medium"
      when 6.6..10.0
        "high"
      else
        "unknown"
      end
    end

    def generate_reported_at
      # avoid timezone issues
      DateTime.parse date.iso8601
    end

    def to_advisory_attributes
      {
        "identifier" => identifier,
        "package_platform" => Platforms::Ruby,
        "package_names" => [gem],
        "patched" => generate_patched,
        "unaffected" => generate_unaffected,
        "title" => title,
        "description" => description,
        "cve_ids" => generate_cve_ids,
        "osvdb_id" => generate_osvdb_id,
        "reported_at" => generate_reported_at,
        "criticality" => generate_criticality,
        "source" => SOURCE
      }
    end
  end
end
