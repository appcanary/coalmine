ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/mock'
require "minitest/reporters"
require 'webmock/minitest'
require 'vcr'
require "minitest/spec"
require 'mocha/mini_test'
require 'helpers/importer_helpers'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class ActiveSupport::TestCase
  include Sorcery::TestHelpers::Rails::Controller
  include ImporterHelpers

  def hydrate(*paths)
    File.read(File.join(Rails.root, "test/data/", *paths))
  end
end

module TestValues
  PASSWORD = "somevaluehere"
end

VCR.configure do |c|
  c.cassette_library_dir = "test/cassettes"
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  # c.default_cassette_options = { :record => :all }
end

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean
