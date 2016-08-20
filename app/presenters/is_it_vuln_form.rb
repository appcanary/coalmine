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
      errors.add(:base, 'Sorry. Are you sure that was a Gemfile.lock? Please try again.')
    else
      self.package_list = pl
    end
  end
end
