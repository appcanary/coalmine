# convenience class for interacting
# with enqueued Que jobs
class QueJob < ActiveRecord::Base
  self.primary_key = 'job_id'
end
