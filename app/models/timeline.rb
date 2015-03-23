class Timeline
  def self.for(user)
    arr = [Event.new(:kind => :new_app)]
    arr.concat 5.times.map { Event.new }
  end
end
