class Platforms
  Debian = "debian"
  Ruby = "ruby"
  CentOS = "centos"

  def self.comparator_for(platform)
    case platform
    when Ruby
      RubyComparator
    when CentOS
      RPMComparator
    else
      nil
    end
  end

  def self.parser_for(platform)
    case platform
    when Ruby
      GemfileParser
    when CentOS
      RPMParser
    else
      nil
    end
  end
end
