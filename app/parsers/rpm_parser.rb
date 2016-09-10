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
# does it make sense for this to be separate?
# like, the RPMComparator does some related stuff right
# Do we trust the user's release input into bundle or 
# package manager or what is written on the package itself?
require 'rpm'
module RPM
  module Parser
    include ResultObject
    def self.parse(file)
      begin
        pkgs = file.each_line.reject { |str|
          str =~ /gpg-pubkey-[a-z0-9]+-[a-z0-9]+/
        }.map { |str|
          Parcel::RPM.new(str)
        }
        Result.new(pkgs, nil)
      rescue Exception => e
        Result.new(nil, e)
      end
    end
  end
end
