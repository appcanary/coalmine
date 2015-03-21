class Timeline
  def self.for(user)
    arr = [Item.new(:kind => :first_app)]
    arr.concat 5.times.map { Item.new }
  end
end
