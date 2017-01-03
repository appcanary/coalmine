# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!
Que.logger = Logger.new(File.join(Rails.root, "log/que_log_maker.log"))
Que.error_notifier = proc do |error, job|
  Raven.capture_exception(error, :extra => { :job => job})
end

# I am not actually sure we only need one worker here.
# TODO: go over this assumption
Que.worker_count = 1
