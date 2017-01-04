class BundleProcessedState < ActiveRecord::Base
  belongs_to :bundle

  def mark_unprocessed!
    self.update_attributes!(processed: false)
  end

  def mark_processed!
    self.update_attributes!(processed: true)
  end
end
