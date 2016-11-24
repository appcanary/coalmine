# by default, ActiveJob sets a "mailers" queue.
# Presently we do not use any specific queues - everything
# listens to the queue list. This got fixed in Rails 5 but in the meantime,
# let's just monkeypatch it, eh?
# source: https://github.com/chanks/que/issues/71
module ActiveJob
  module QueueAdapters
    class QueAdapter
      def self.enqueue(job)
        JobWrapper.enqueue job.serialize
      end

      def self.enqueue_at(job, timestamp)
        JobWrapper.enqueue job.serialize, run_at: Time.at(timestamp)
      end
    end
  end
end
