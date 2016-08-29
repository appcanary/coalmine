require 'fileutils'
class GitHandler
  attr_accessor :klass_name, :repo_url, :local_path
  def initialize(klass, url, path)
    self.klass_name = klass.name
    self.repo_url = url
    self.local_path = path
  end

  def fetch_and_update_repo!
    if File.exists?(local_path)
      unless system("cd #{local_path} && git pull")
        raise "#{klass_name}: something went wrong pulling"
      end
    else
      FileUtils.mkdir_p(local_path)
      unless system("git clone #{repo_url} #{local_path}")
        raise "#{klass_name}: something went wrong cloning"
      end
    end
  end
end
