class Platforms
  Debian = "debian"
  Ruby = "ruby"

  def self.comparator_for(platform)
    case platform
    when Ruby
      RubyComparator
    else
      nil
    end
  end

  def self.parser_for(platform)
    case platform
    when Ruby
      GemfileParser
    else
      nil
    end
  end
end
