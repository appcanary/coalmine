module DpkgPackageParser
  include ResultObject
  def self.parse(statusfile)
    begin
      pkg_hshs = statusfile.split(/\n\n(?!\s)/).map do |package|
        ppairs = package.split(/\n(?!\s)/).map do |line|
          line.split(":", 2).map(&:strip)
        end

        Hash[ppairs]
      end

      pkgs = pkg_hshs.map do |hsh|
        Parcel::Dpkg.new(hsh)
      end

      Result.new(pkgs, nil)
    rescue Exception => e
      Result.new(nil, e)
    end
  end
end
