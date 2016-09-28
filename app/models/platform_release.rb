class PlatformRelease
  include ResultObject 

  class Validator
    include ActiveModel::Validations
    validate :correct_platform_and_release

    attr_accessor :platform, :release
    def initialize(platform, release)
      self.platform = platform
      self.release = release
    end

    def correct_platform_and_release
      valid_releases = Platforms.releases_for(platform)

      if valid_releases.nil?
        errors.add(:platform, "is invalid")
        return
      end


      if platform == Platforms::Ubuntu
        # be weary of nil release values
        if release
          # filter out 14.04.3 down to 14.04
          match = /^(\d+\.\d+)(\.\d+)?/.match(self.release)
          if match
            self.release = match[1]
          end
        end
      end

      if (rel_match = valid_releases[release]).blank?
        errors.add(:release, "is invalid")
      end

      # for ubuntu, debian
      if rel_match.is_a? String
        self.release = rel_match
      end
    end
  end

  def self.validate(platform, release = nil)
    pr = Validator.new(platform, release)

    if pr.valid?
      return Result.new(pr, nil)
    else
      return Result.new(nil, pr.errors)
    end
  end
end
