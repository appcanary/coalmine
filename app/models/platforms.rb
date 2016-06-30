class Platforms
  Debian = "debian"
  Ubuntu = "ubuntu"
  Ruby = "ruby"
  CentOS = "centos"

  @all_platforms = [
    Debian,
    Ubuntu,
    CentOS,
    Ruby
  ]

  class Releases
    UbuntuReleases = ["16.04", "15.10", "15.04", "14.04", "12.04"]
    DebianReleases = ["8", "7", "6", "5"]
    CentOSReleases = ["7"]

    @platform_to_release = {
      Debian => DebianReleases,
      Ubuntu => UbuntuReleases,
      CentOS => CentOSReleases
    }

    def self.for(platform)
      @platform_to_release[platform] || []
    end
  end
 
  def self.select_platform_release
    arr = [Ruby.titleize]

    arr += [Ubuntu, CentOS, Debian].map do |plt|
      Releases.for(plt).map { |r| "#{plt.titleize} - #{r}" }
    end.flatten

    arr
  end

  def self.select_opt_to_h(str)
    return nil unless str

    platform, release = str.downcase.split(" - ")
    if @all_platforms.include?(platform)
      pr_releases = Releases.for(platform)
      # if we care about releases, check against them
      if pr_releases.present? && pr.include?(release)
        return {platform: platform, release: release}
      else
        return {platform: platform}
      end
    end
    nil
  end
end
