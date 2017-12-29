require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

APPCANARY_HOST = {
  "development" => "canary.dev:3000",
  "test" => "canary.dev:3000",
  "staging" => "staging.appcanary.com",
  "production" => "appcanary.com"
}
APPCANARY_HTTP_PROTOCOL = Hash.new("https").tap do |h|
  h["development"] = "http"
end

ACQUIRED_TEXT = "Hey! We're shutting down. Find out more by <a href='http://blog.appcanary.com/2018/goodbye.html'>clicking here</a>.".html_safe

module CanaryWeb
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # prevent fields with errors from being wrapped with a div
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| html_tag.html_safe }

    config.active_record.schema_format = :sql

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('lib/canary')

    
    # SIGH http://stackoverflow.com/a/15539534/142266
    config.action_mailer.asset_host = "#{APPCANARY_HTTP_PROTOCOL[Rails.env]}://#{APPCANARY_HOST[Rails.env]}"

    # custom errors
    config.exceptions_app = self.routes

    config.active_job.queue_adapter = :que

    if ENV["QUE_RUNNING"]
      config.logger = Logger.new(File.join(Rails.root, "log/que_worker.log"))
    end
    
  end
end


Rails.application.routes.default_url_options[:protocol] = APPCANARY_HTTP_PROTOCOL[Rails.env]
Rails.application.routes.default_url_options[:host] = APPCANARY_HOST[Rails.env]
