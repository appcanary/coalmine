=begin
(defn parse-rpm-package-list
  "Parse the results of `rpm -qa`"
  [input server]
  (doall
   (for [package (string/split-lines input) :when (not (re-matches #"gpg-pubkey-[a-z0-9]+-[a-z0-9]+" package))] ;; We need to filter out entries like "gpg-pubkey-f4a80eb5-53a7ff4b". These are public keys we accept packages from and not actual packages
     (let [nevra (package->nevra package)]
       {:name (:name nevra)
        :kind "centos"
        :version {:number (package->evr-str package)
                  :platform (or (package->os-release package) (:release server))
                  :arch (:arch nevra)}}))))

=end

# TODO
# test obv
# does it make sense for this to be separate?
# like, the RPMComparator does some related stuff right
# Do we trust the user's release input into bundle or 
# package manager or what is written on the package itself?
class RPMParser
  class Nevra
    NEVRA_REGEXP = /^(.*)-(.*)-(.*)\.([^\.]*)$/
    attr_accessor :name, :epoch, :version, :release, :arch
    def initialize(str)
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
  end

  def self.parse(file)
    file.each_line.reject { |str|
      str =~ /gpg-pubkey-[a-z0-9]+-[a-z0-9]+/
    }.map { |str|
      Nevra.new(str.strip)
    }
  end
end
