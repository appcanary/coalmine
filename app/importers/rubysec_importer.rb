class RubysecImporter < AdvisoryImporter
  SOURCE = "rubysec"
  REPO_URL = "https://github.com/rubysec/ruby-advisory-db.git"
  REPO_PATH = "tmp/importers/rubysec"

  def initialize(repo_path = nil, repo_url = nil)
    @repo_url = repo_url || REPO_URL
    @repo_path = repo_path || REPO_PATH
  end

  def local_path
    File.join(Rails.root, @repo_path)
  end

  def fetch_advisories
     git = GitHandler.new(self.class, @repo_url, local_path)
    git.fetch_and_update_repo!

    Dir[File.join(local_path, "gems", "/**/**yml")]  
  end

  def parse(ymlfile)
    hsh = YAML.load_file(ymlfile)
    RubysecAdvisory.new({"filepath" => ymlfile}.merge(hsh))
  end
end
