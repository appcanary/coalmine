class AlpineImporter < AdvisoryImporter
  SOURCE = "alpine"
  PLATFORM = Platforms::Alpine
  REPO_URL = "https://git.alpinelinux.org/cgit/alpine-secdb"
  REPO_PATH = "tmp/importers/alpine-secdb"

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
    # Files are organized by structure, like this:
    #
    #   ./distroversion/reponame.yaml
    #
    # but version and repo name are included as top level attriutes in the YAML
    # file
    Dir.glob(File.join(local_path, "/**/*.yaml"))
  end

  def parse(ymlfile)
    repo_hsh = YAML.load_file(ymlfile)

    repo_hsh["packages"].map do |pkg_entry|
      pkg = pkg_entry["pkg"]
      pkg["secfixes"].map do |(pkg_ver, cve_list)|
        hsh = repo_hsh.slice("distroversion", "reponame")

        hsh["package_name"] = pkg["name"]
        hsh["package_version"] = pkg_ver

        # Xen vulns contain the XSA along with CVE, i.e. "CVE-2016-9386 XSA-191"
        hsh["cve_list"] = cve_list.flat_map { |r| r.split }

        hsh["download_apks"] = urls_for_apk(repo_hsh["archs"],
                                      repo_hsh["urlprefix"],
                                      repo_hsh["distroversion"],
                                      repo_hsh["reponame"],
                                      pkg["name"],
                                      pkg_ver)

        # repo_hsh is the whole YAML file
        # TODO some subset?
        AlpineAdapter.new(hsh, repo_hsh)
      end
    end.flatten
  end

  private
  def urls_for_apk(archs, prefix, version, repo, pkg_name, pkg_ver)
    archs.map { |arch| "#{prefix}/#{version}/#{repo}/#{arch}/#{pkg_name}-#{pkg_ver}.apk"}
  end
end
