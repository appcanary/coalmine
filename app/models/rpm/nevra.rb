module RPM
  class Nevra
    NEVRA_REGEXP = /^(.*)-(.*)-(.*)\.([^\.]*)$/
    attr_accessor :filename, :name, :epoch, :version, :release, :arch
    def initialize(str)
      self.filename = str
      str_sans_ext = str.gsub(/\.rpm$/, "")
      matches = NEVRA_REGEXP.match(str_sans_ext).to_a

      _, self.name, version_epoch, self.release, self.arch = matches

      # If the version has ":", the first part is the epoch. Otherwise the epoch is "0"

      if version_epoch.index(":")
        self.epoch, self.version = version_epoch.split(":")
      else
        self.epoch = "0"
        self.version = version_epoch
      end
    end

    def [](key)
      to_h[key]
    end

    def to_h
      {name: name,
       epoch: epoch,
       version: version,
       release: release,
       arch: arch}
    end

    def to_package
      Package.new(name: name,
                  epoch: epoch,
                  version: version,
                  version_release: release,
                  arch: arch)
    end
  end
end
