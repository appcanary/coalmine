class Checker
  attr_accessor :account, :platform, :release

  def initialize(account, environ)
    self.account = account
    self.platform = environ[:platform]
    self.release = environ[:release]
  end

   # TODO: validation, natch

  def check(package_list)
    # parser = Platforms.parser_for(platform)
    # package_list = parser.parse(package_file)

    package_query = PackageMaker.new(platform, release).find_or_create(package_list)


    vuln_query = package_query.includes(:vulnerabilities).references(:vulnerabilities).where("vulnerabilities.id IS NOT NULL")
  end
end
