class RubysecImporter
  SOURCE = "rubysec"
  REPO_URL = "https://github.com/rubysec/ruby-advisory-db.git"
  REPO_PATH = "tmp/importer/rubysec"

  def initialize(repo_path = nil, repo_url = nil)
    @repo_url = repo_url || REPO_URL
    @repo_path = repo_path || REPO_PATH
  end

  def import!
    git = GitHandler.new(self.class, @repo_url, local_path)
    git.fetch_and_update_repo!

    raw_advisories = fetch_advisories
    all_advisories = raw_advisories.map { |ra| parse(ra) }
    process_advisories(all_advisories)
  end

  def local_path
    File.join(Rails.root, @repo_path)
  end

  
  def fetch_advisories
    Dir[File.join(local_path, "gems", "/**/**yml")]  
  end

  def parse(ymlfile)
    hsh = YAML.load_file(ymlfile)
    RubysecAdvisory.new(ymlfile, hsh)
  end

  def process_advisories(all_advisories)
    all_advisories.each do |adv|
      qadv = QueuedAdvisory.most_recent_advisory_for(adv.identifier, SOURCE).first

      if qadv.nil?
        # oh look, a new advisory!
        QueuedAdvisory.create!(adv.to_advisory_attributes)
      else
        if has_changed?(qadv, adv)
          QueuedAdvisory.create!(adv.to_advisory_attributes)
        end
      end
    end
  end

  def has_changed?(existing_advisory, adv)
    new_attributes = adv.to_advisory_attributes
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

    # use the actual file path as an identifier
    # will break when we switch away from OSVDB
    def identifier
      filepath.split("/")[-2..-1].join("/")
    end

    def to_constraint(c, n)
      {"constraint" => c, "name" => n}
    end

    def generate_patched
      if patched_versions
        patched_versions.map do |pv|
          to_constraint(pv, gem)
        end
      else
        []
      end
    end

    def generate_unaffected
      if unaffected_versions
        unaffected_versions.map do |uv|
          to_constraint(uv, gem)
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
      @advisory_attributes ||= 
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
