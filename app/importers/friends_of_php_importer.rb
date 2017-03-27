require_relative File.join(Rails.root, 'lib/git_handler')

class FriendsOfPHPImporter < AdvisoryImporter
  SOURCE = "friendsofphp"
  PLATFORM = Platforms::PHP
  REPO_URL = "https://github.com/FriendsOfPHP/security-advisories.git"
  REPO_PATH = "tmp/importers/friendsofphp"

  def initialize(repo_path = nil, repo_url = nil)
    @repo_url = repo_url || REPO_URL
    @repo_path = repo_path || REPO_PATH
  end

  def local_path
    File.join(Rails.root, @repo_path)
  end

  def update_local_store!
    git = GitHandler.new(self.class, @repo_url, local_path)
    git.fetch_and_update_repo!
  end

  def fetch_advisories
    Dir[File.join(local_path, "/**/**yaml")]
  end

  def parse(ymlfile)
    hsh = YAML.load_file(ymlfile)
    everything = {"filepath" => ymlfile}.merge(hsh)
    FriendsOfPHPAdapter.new(everything, everything)
  end
end
