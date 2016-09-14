class Jobber < Que::Job
  def log(string, level = :info)
    Que.log :level => level, :object_id => self.object_id, :job_class => @attrs["job_class"], :msg => string
  end
end
