class WebhookForm < Reform::Form
  property :url


  validate :url do
    if url.blank?
      errors.add(:url, "must not be blank")
    elsif !url_valid?(url)
      errors.add(:url, "must be a valid URL")
    end

  end

  def url_valid?(url)
    url = URI.parse(url) rescue false
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
  end
end
