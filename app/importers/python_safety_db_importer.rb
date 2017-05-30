require_relative File.join(Rails.root, "lib/git_handler")

class PythonSafetyDbImporter < AdvisoryImporter
  SOURCE = "safety-db"
  PLATFORM = Platforms::Python
  REPO_URL = "https://github.com/pyupio/safety-db.git"
  REPO_PATH = "tmp/importers/python-safety-db"

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
    [File.open(File.join(local_path, "data/insecure_full.json")).read]
  end

  def parse(json)
    advisories = JSON.parse(json).reduce([]) do |acc, (k, v)|
      acc.concat v.map { |adv| PythonAdapter.new(adv.merge({"package_name" => k})) }
    end
  end
end
