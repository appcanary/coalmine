ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/mock'
require "minitest/reporters"
require 'webmock/minitest'
require 'vcr'
require "minitest/spec"
require 'mocha/mini_test'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  include Sorcery::TestHelpers::Rails::Controller
  # Add more helper methods to be used by all tests here...

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
  # c.default_cassette_options = { :record => :all }
end

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean
