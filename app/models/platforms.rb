require File.join(Rails.root, "app/parsers", 'rpm_parser')
class Platforms
  # TODO cleanup old platforms code
  Debian = "debian"
  Ubuntu = "ubuntu"
  Ruby = "ruby"
  CentOS = "centos"
  Amazon = "amzn"

  @all_platforms = [
    Debian,
    Ubuntu,
    CentOS,
    Ruby,
    Amazon
  ]

  class Releases
    UbuntuReleases = ["16.04", "15.10", "15.04", "14.04", "12.04"]
    DebianReleases = ["8", "7", "6", "5"]
    CentOSReleases = ["7"]
    AmazonReleases = ["2016.03"]

    @platform_to_release = {
      Debian => DebianReleases,
      Ubuntu => UbuntuReleases,
      CentOS => CentOSReleases,
      Amazon => AmazonReleases
    }

    def self.for(platform)
      @platform_to_release[platform] || []
    end
  end
 
  def self.select_platform_release
    arr = [Ruby.titleize]

    arr += [Ubuntu, CentOS, Debian, Amazon].map do |plt|
      Releases.for(plt).map { |r| "#{plt.titleize} - #{r}" }
    end.flatten

    arr
  end

  def self.select_opt_to_h(str)
    return nil unless str

    platform, release = str.downcase.split(" - ")
    if @all_platforms.include?(platform)
      pr_releases = Releases.for(platform)
      # if we care about releases, check against them
      if pr_releases.present? && pr_releases.include?(release)
        return {platform: platform, release: release}
      else
        return {platform: platform}
      end
    end
    nil
  end


  ## new api platforms as follows:
  RELEASES = {
    Ruby => { nil => true },
    Amazon => { "2016.03" => true },
    CentOS => { "7" => true },
    Ubuntu => {
      "4.10"=>"warty",
      "5.04"=>"hoary",
      "5.10"=>"breezy",
      "6.04"=>"drake",
      "6.10"=>"edgy",
      "7.04"=>"feisty",
      "7.10"=>"gusty",
      "8.04"=>"hardy",
      "8.10"=>"intrepid",
      "9.04"=>"jaunty",
      "9.10"=>"karmic",
      "10.04"=>"lucid",
      "10.10"=>"maverick",
      "11.04"=>"natty",
      "12.04"=>"precise",
      "12.10"=>"quantal",
      "13.04"=>"raring",
      "13.10"=>"saucy",
      "14.04"=>"trusty",
      "14.10"=>"utopic",
      "15.04"=>"vivid",
      "15.10"=>"wily",
      "16.04"=>"xenial",
      "warty"=> true,
      "hoary"=> true,
      "breezy"=> true,
      "drake"=> true,
      "edgy"=> true,
      "feisty"=> true,
      "gusty"=> true,
      "hardy"=> true,
      "intrepid"=> true,
      "jaunty"=> true,
      "karmic"=> true,
      "lucid"=> true,
      "maverick"=> true,
      "natty"=> true,
      "precise"=> true,
      "quantal"=> true,
      "raring"=> true,
      "saucy"=> true,
      "trusty"=> true,
      "utopic"=> true,
      "vivid"=> true,
      "wily"=> true,
      "xenial" => true,

    },
    Debian => {
      "2.1" => "slink",
      "2.2" => "potato",
      "3.0" => "woody",
      "3.1" => "sarge",
      "4" => "etch",
      "5" => "lenny",
      "6" => "squeeze",
      "7" => "wheezy",
      "8" => "jessie",
      "slink"=> true,
      "potato"=> true,
      "woody"=> true,
      "sarge"=> true,
      "etch"=> true,
      "lenny"=> true,
      "squeeze"=> true,
      "wheezy"=> true,
      "jessie"=> true,
    } 
  }

  def self.releases_for(platform)
    RELEASES[platform]
  end

  def self.comparator_for(package)
    klass = case package.platform
            when Ruby
              RubyComparator
            when CentOS
              RPMComparator
            when Ubuntu
              DpkgComparator
            when Debian
              DpkgComparator
            else
              raise "unknown platform for comparator"
            end
 
    klass.new(package)
  end

  def self.parser_for(platform)
    case platform
    when Ruby
      GemfileParser
    when CentOS
      RPM::Parser
    when Ubuntu
      DpkgStatusParser
    when Debian
      DpkgStatusParser
    else
      nil
    end
  end
end
