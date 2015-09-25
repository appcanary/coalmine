if Rails.env.production?
  Analytics = Segment::Analytics.new({
    write_key: Rails.configuration.segment.key,
    on_error: Proc.new { |status, msg| print msg }
  })
end
