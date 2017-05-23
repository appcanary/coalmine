class ApkInstalledDbParser
  include ResultObject

  def self.parse(installed)
    packages = installed.split("\n\n").map { |pkg| pkg.split("\n") }

    packages = packages.map do |pkg_lines|
      hsh = {}
      pkg_lines.each do |line|
        val = line[2..-1]
        case line[0]
        when "P"
          hsh["name"] = val
        when "V"
          hsh["version"] = val
        end
      end

      Parcel::APK.new(hsh)
    end

    Result.new(packages, nil)
  end
end
