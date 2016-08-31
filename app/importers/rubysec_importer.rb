class RubysecImporter
  SOURCE = "rubysec"
  REPO_URL = "https://github.com/rubysec/ruby-advisory-db.git"
  REPO_PATH = "tmp/importers/rubysec"

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
    RubysecAdvisory.new({"filepath" => ymlfile}.merge(hsh))
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

end
