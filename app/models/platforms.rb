require File.join(Rails.root, "app/parsers", 'rpm_parser')
class Platforms
  Ubuntu = "ubuntu"
  Debian = "debian"
  Ruby = "ruby"
  CentOS = "centos"

  RELEASES = {
    Ruby => { nil => true },
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
      "16.04"=>"xenial"
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
      "8" => "jessie"
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
    else
      nil
    end
  end
end
