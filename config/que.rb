# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!
EmailNotifyJob.enqueue_if_not_existing!
