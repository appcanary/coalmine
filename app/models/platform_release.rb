class PlatformRelease
  include ResultObject 

  class Validator
    include ActiveModel::Validations
    validate :correct_platform_and_release

    attr_accessor :platform, :release, :release_name
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

      if (rel_match = valid_releases[release]).blank?
        errors.add(:release, "is invalid")
      end

      # for ubuntu, debian
      if rel_match.is_a? String
        self.release_name = rel_match
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
