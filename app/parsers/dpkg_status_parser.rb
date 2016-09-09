=begin
(defn parse-line [line]
  (->> (str/split line #":" 2)
       (mapv str/trim)))

(defn parse-package-list
  [input {:keys [distro release] :as server}]
  (doall
   (remove nil?
           (for [package (str/split input #"\n\n(?!\s)")]
             (let [pairs (->> (str/split package #"\n(?!\s)")
                              (mapv parse-line)
                              (into {}))
                   release (release-name distro release)
                   status (get pairs "Status")
                   source (when-let [source (get pairs "Source")]
                            (first (str/split source #"\s"))) ;; Sometimes source package is a line like "linux-latest (63)" where the number is the source package version. We make the artifact depend on the source package name
                   pkg-name (get pairs "Package")]
               (when (or (= distro "unknown")
                         (= release "unknown"))
                 (throw (ex-info "Unknown release or distro" {:distro distro
                                                              :release release
                                                              :server server})))

               (when (= status "install ok installed")
                 {:name    pkg-name
                  :kind    distro
                  :source (or source pkg-name)
                  :version {:number   (get pairs "Version")
                            :platform release}}))))))

=end
module DpkgStatusParser
  include ResultObject
  def self.parse(statusfile)
    pkg_hshs = statusfile.split(/\n\n(?!\s)/).map do |package|
      ppairs = package.split(/\n(?!\s)/).map do |line|
        line.split(":", 2).map(&:strip)
      end

      Hash[ppairs]
    end
      
    installed_pkgs = pkg_hshs.select do |hsh|
      hsh["Status"] == "install ok installed"
    end
      
    installed_pkgs.map do |hsh|
      Parcel::Dpkg.new(hsh)
    end
  end
end
