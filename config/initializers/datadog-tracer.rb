if Rails.env.production?
  Rails.configuration.datadog_trace = {
    auto_instrument: true,
    auto_instrument_redis: true,
    default_service: 'coalmine'
  }
end
