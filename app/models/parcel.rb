class Parcel
  attr_accessor :platform, :release, :name, :version

  def self.from_package(package)
    klass = self.for_platform(package.platform)

    klass.builder_from_package(package)
  end

  # What parcel do we need for a given platform?
  def self.for_platform(platform)
    case platform
    when Platforms::Ruby
      Parcel::Rubygem
    when Platforms::CentOS
      Parcel::RPM
    when Platforms::Amazon
      Parcel::RPM
    when Platforms::Ubuntu
      Parcel::Dpkg
    when Platforms::Debian
      Parcel::Dpkg
    else
      raise "unknown platform"
    end
  end

  def self.builder_from_package(pkg)
    builder = self.new
    builder.platform = pkg.platform
    builder.release = pkg.release
    builder.name = pkg.name
    builder.version = pkg.version
    builder
  end

  def self.builder_from_hsh(hsh)
    # Makes a parcel from an attributes hash.
    # This will throw an error if the hash has a key the parcel doesn't know about
    builder = self.new
    hsh.each do |k, v|
      builder.send("#{k}=", v)
    end
    builder
  end

  def attributes
    {platform: platform, release: release,
     name: name, version: version }
  end

  def unique_values
    [self.name, self.version]
  end

  def unique_hash
    {'name' => self.name, 'version' => self.version}
  end
  class RPM < Parcel
    attr_accessor :arch, :filename, :nevra

    def self.builder_from_package(pkg)
      builder = super

      builder.arch = pkg.arch
      builder.filename = pkg.filename

      builder
    end

    def initialize(filename = nil)
      return if filename.nil?
      self.filename = filename
      self.nevra = ::RPM::Nevra.new(filename.strip)

      self.name = nevra.name
      self.version = filename
      self.arch = nevra.arch

      # Centos has "alt" packages for Xen4CentOS and software collections.
      # we tag them in the name with "^alt"
      if nevra.release.ends_with?(".alt")
        self.name = self.name + "^alt"
      end
    end

    def attributes
      {
        platform: platform,
        release: release,
        name: name,
        version: version,
        arch: arch,
        filename: filename
      }
    end

  end

  class Rubygem < Parcel
    def initialize(hsh = nil)
      return if hsh.nil?
      self.name = hsh[:name]
      self.version = hsh[:version]
    end
  end

  class Dpkg < Parcel
    attr_accessor :source_name, :source_version
    def initialize(hsh = nil)
      return if hsh.nil?

      self.name = hsh["Package"]
      self.version = hsh["Version"]

      if src = hsh["Source"]
        if src.index("(")
          _, self.source_name, self.source_version = src.split(/(?<name>[^\s]+) \((?<version>[^\s]+)\)/)
        else
          self.source_name = src
        end
      end
    end

    def attributes
      {
        platform: platform,
        release: release,
        name: name,
        version: version,
        source_name: source_name,
        source_version: source_version
      }
    end
  end
end
