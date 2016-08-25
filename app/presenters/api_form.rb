class ApiForm < Reform::Form
  attr_accessor :package_list, :platform_release

  property :name, :virtual => true
  property :platform
  property :release
  property :file, :virtual => true

  def file_contents
    @file_contents ||= file.read
  end

  validate :platform_release do
    val, err = PlatformRelease.validate(platform, release)

    if err
      errors.add(:platform, "is invalid")
    else
      self.platform_release = val
    end
  end


  validate :file do
    if file.blank?
      errors.add(:base, "Hey, you have to upload a file for this to work!")
      next 
    end

    parser = Platforms.parser_for(Platforms::Ruby)

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
