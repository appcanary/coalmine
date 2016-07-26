ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/spec"
require "minitest/reporters"
require 'mocha/mini_test'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  def hydrate(name)
    File.read(File.join(Rails.root, "test/fixtures/#{name}"))
  end
end
