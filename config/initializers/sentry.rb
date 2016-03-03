Raven.configure do |config|
  # config.dsn is set from the SENTRY_DSN environment variable (in upstart)
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
