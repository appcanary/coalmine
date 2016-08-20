class Parcel
  attr_accessor :platform, :release, :name, :version

  # used solely to build objects for testing
  def self.from_package(package)
    klass = case package.platform
            when Platforms::Ruby
              Parcel::Rubygem
            when Platforms::CentOS
              Parcel::RPM
            else
              raise "unknown platform"
            end

    klass.builder_from_package(package)
  end

  def self.builder_from_package(pkg)
    builder = self.new
    builder.platform = pkg.platform
    builder.release = pkg.release
    builder.name = pkg.name
    builder.version = pkg.version
    builder
  end

  def attributes
    {platform: platform, release: release,
     name: name, version: version }
  end

  def unique_values
    [self.name, self.version]
  end

  class RPM < Parcel
    attr_accessor :arch, :filename, :nevra

    def self.builder_from_package(pkg)
      builder = super

      builder.arch = pkg.arg
      builder.filename = pkg.filename

      builder
    end

    def initialize(filename = nil)
      return if filename.nil?
      self.filename = filename
      self.nevra = ::RPM::Nevra.new(filename.strip)

      self.name = nevra.name
      self.version = nevra.to_evra
      self.arch = nevra.arch
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
    def initialize(hsh = nil)
      return if hsh.nil?
      self.name = hsh[:name]
      self.version = hsh[:version]
    end
  end
end
