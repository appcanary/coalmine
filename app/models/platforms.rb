require File.join(Rails.root, "app/parsers", 'rpm_parser')
class Platforms
  Debian = "debian"
  Ubuntu = "ubuntu"
  Ruby = "ruby"
  CentOS = "centos"
  Amazon = "amzn"
  None = "none"

  FULL_NAMES = {
    Ruby => "Ruby",
    Amazon => "Amazon",
    CentOS => "CentOS",
    Ubuntu => "Ubuntu",
    Debian => "Debian"
  }

  OPERATING_SYSTEMS = [
    Ubuntu,
    Debian,
    CentOS,
    Amazon
  ]

  PLATFORM_RELEASES = {
    Ruby => [ nil ],
    Amazon => [ nil ],
    Debian => [
      ["2.1","slink"],
      ["2.2","potato"],
      ["3.0","woody"],
      ["3.1","sarge"],
      ["4","etch"],
      ["5","lenny"],
      ["6","squeeze"],
      ["7","wheezy"],
      ["8","jessie"],
    ],
    Ubuntu => [
      ["4.10","warty"],
      ["5.04","hoary"],
      ["5.10","breezy"],
      ["6.04","drake"],
      ["6.10","edgy"],
      ["7.04","feisty"],
      ["7.10","gusty"],
      ["8.04","hardy"],
      ["8.10","intrepid"],
      ["9.04","jaunty"],
      ["9.10","karmic"],
      ["10.04","lucid"],
      ["10.10","maverick"],
      ["11.04","natty"],
      ["12.04","precise"],
      ["12.10","quantal"],
      ["13.04","raring"],
      ["13.10","saucy"],
      ["14.04","trusty"],
      ["14.10","utopic"],
      ["15.04","vivid"],
      ["15.10","wily"],
      ["16.04","xenial"],
      ["16.10","yakkety"],
      ["17.04","zesty"],
    ],
    CentOS => [
      "5",
      "6",
      "7"
    ],
  }

  PLATFORMS_WITH_UNAFFECTED = [Ruby]
  PLATFORMS_WITH_RELEASES = PLATFORM_RELEASES.reduce([]) { |arr,(plt,rels)|
    if rels.compact.any?
      arr << plt
    end
    arr
  }

  # This constructs a hash of platform-name to hash of
  # valid platform-releases. This hash is used for
  # validating user-input release values.
  #
  # There is some mild gotcha concerning how it untangles
  # version names vs codenames; debian&ubuntu provide versions
  # but actually use codenames internally. The PlatformRelease class
  # uses this class to go from version to codename.

  PLATFORM_TO_RELEASE = Hash.new.tap do |hsh|
    PLATFORM_RELEASES.each do |platform, releases|
      h = Hash.new

      releases.each do |rel, nam|
        if nam
          h[rel] = nam
          h[nam] = true
        elsif rel
          h[rel] = true
        else
          # Has no releases, do nothing
        end
      end

      hsh[platform] = h
    end
  end


  @all_platforms = [
    Debian,
    Ubuntu,
    CentOS,
    Ruby,
    Amazon
  ]

  def self.all_platforms
    @all_platforms
  end

  def self.select_platform_release
    arr = [[FULL_NAMES[Ruby], Ruby],
           [FULL_NAMES[Amazon], Amazon]]

    arr += [Ubuntu, CentOS, Debian].map do |plt|
      PLATFORM_RELEASES[plt].map { |r,v| ["#{FULL_NAMES[plt]} - #{r}", "#{plt} - #{r}"] }
    end.flatten(1)
  end


  def self.supported?(platform)
    self.full_name(platform)
  end

  def self.full_name(platform)
    FULL_NAMES[platform]
  end

  def self.releases_for(platform)
    case platform
    when Debian
      PLATFORM_RELEASES[platform].map(&:first)[-6..-1].reverse
    when Ubuntu
      PLATFORM_RELEASES[platform].map(&:first)[-6..-1].reverse
    when Ruby
      nil
    else
      PLATFORM_RELEASES[platform]
    end
  end

  def self.valid_releases_for(platform)
    PLATFORM_TO_RELEASE[platform]
  end

  def self.comparator_for(package)
    klass = case package.platform
            when Ruby
              RubyComparator
            when CentOS
              RPMComparator
            when Amazon
              # TODO: smokescreen test this
              RPMComparator
            when Ubuntu
              DpkgComparator
            when Debian
              DpkgComparator
            else
              raise "unknown platform for comparator"
            end

    klass.new(package.version)
  end

  def self.parser_for(platform)
    case platform
    when Ruby
      GemfileParser
    when CentOS
      RPM::Parser
    when Amazon
      # TODO: smokescreen test this
      RPM::Parser
    when Ubuntu
      DpkgStatusParser
    when Debian
      DpkgStatusParser
    else
      nil
    end
  end

  def self.select_operating_systems
    OPERATING_SYSTEMS.map { |n| [n, full_name(n)] }
  end
end
