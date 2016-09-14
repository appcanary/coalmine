# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!
Que.logger = Logger.new(File.join(Rails.root, "log/que.log"))

# make sure we enqueue some basic stuff
# handle emails
EmailNotifyJob.enqueue_if_not_existing!

# import data
AlasImporterJob.enqueue_if_not_existing!
CesaImporterJob.enqueue_if_not_existing!
RubysecImporterJob.enqueue_if_not_existing!
UbuntuTrackerImporterJob.enqueue_if_not_existing!
DebianTrackerImporterJob.enqueue_if_not_existing!

# process imported data
VulnerabilityImporterJob.enqueue_if_not_existing!
