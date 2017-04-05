class FriendsOfPHPAdapter < AdvisoryAdapter.new(:filepath, :cve, :link, :title,
                                                :reference, :branches)

  # title:     HTTP Proxy header vulnerability
  # link:      https://github.com/bugsnag/bugsnag-laravel/releases/tag/v2.0.2
  # cve:       CVE-2016-5385
  # branches:
  #     master:
  #         time:     2016-07-18 20:27:36
  #         versions: ['>=2', '<2.0.2']
  # reference: composer://bugsnag/bugsnag-laravel

  def identifier
    filepath.split("/")[-3..-1].join("/")
  end

  def source
    FriendsOfPHPImporter::SOURCE
  end

  def platform
    FriendsOfPHPImporter::PLATFORM
  end

  def package_name
    reference.split("composer://").last
  end

  generate :constraints do
    hshs = []

    if branches.present?
      hshs = branches.map do |k, v|
        {"package_name" => package_name,
         "affected_versions" => v["versions"]}
      end
    end

    hshs.map { |hsh| DependencyConstraint.parse(hsh) }
  end

  generate :reference_ids do
    cve.strip! unless cve.nil?

    if cve && cve != "~"
      [cve]
    else
      []
    end
  end

  def package_version(name, version_constraint)
    {"package_name" => name, "version" => version_constraint}
  end

  generate :affected do
    if branches.present?
      branches.
        map { |k, v| v["versions"] }.
        map { |v| package_version(package_name, v) }
    else
      []
    end
  end

  generate :title do
    title
  end
end
