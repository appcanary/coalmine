# TODO: merge relevant select code from Platforms.
# TODO: test
class MonitorForm < Reform::Form
  attr_accessor :platform_release, :package_list

  property :name
  property :file, :virtual => true
  property :platform_release_str, :virtual => true

  def split_platform_release
    @split_platform_release ||= self.platform_release_str.downcase.split(" - ")
  end

  def file_contents
    @file_contents ||= file.read
  end

  validates :name, :presence => true

  validate :platform_release do
    platform, release = split_platform_release
    val, err = PlatformRelease.validate(platform, release)

    if err
      errors.add(:platform_release_str, "is invalid")
    else
      self.platform_release = val
    end
  end

  # depends on pr validation
  # validations should be idempotent
  validate :file do
    next if errors.present?

    if file.nil?
      errors.add(:file, "is empty")
    else

      parser = Platforms.parser_for(self.platform_release.platform)

      pl, err = parser.parse(file_contents)

      if err
        errors.add(:file, err.message)
      elsif pl.empty?
        errors.add(:file, "has no listed packages. Are you sure it's valid?")
      else
        self.package_list = pl
      end
    end
  end
end
