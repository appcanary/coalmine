class IsItVulnForm < Reform::Form
  attr_accessor :package_list

  property :file, :virtual => true

  def file_contents
    @file_contents ||= file.read
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
