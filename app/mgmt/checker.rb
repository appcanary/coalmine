class Checker
  attr_accessor :account, :platform, :release

  def initialize(account, environ)
    self.account = account
    self.platform = environ[:platform]
    self.release = environ[:release]
  end

   # TODO: validation, natch

  def check(package_file)
    parser = Platforms.parser_for(platform)
    package_list = parser.parse(package_file)

    package_query = nil
    Package.transaction do
      package_query = PackageMaker.new(platform, release).find_or_create(package_list)
    end


    # TODO
    # either denormalize or find a way to make this
    # query not be terrible and N+1, re: advisories
    vuln_query = package_query.includes(:vulnerabilities).references(:vulnerabilities).where("vulnerabilities.id IS NOT NULL")

    # Result.new(vuln_query)
  end
end
