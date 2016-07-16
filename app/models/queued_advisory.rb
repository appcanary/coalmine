class QueuedAdvisory < ActiveRecord::Base
  def advisory_attributes
    self.attributes.except("id")
  end
end
