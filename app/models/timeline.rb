class Timeline
  def self.for(user)
    arr = [Event.new(:kind => :new_server,
                     :server => Server.new(:name => "demo-server-53"))]
  end
end
