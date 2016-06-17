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
end
