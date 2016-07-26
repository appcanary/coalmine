require File.join(Rails.root, "app/parsers", 'rpm_parser')
class Platforms
  Debian = "debian"
  Ruby = "ruby"
  CentOS = "centos"

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
