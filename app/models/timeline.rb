class Timeline
  def self.for(user)
    server = Server.new(:name => "droplet37a")
    arr = [Event.new(:kind => :new_server,
                     :created_at => Time.now,
                     :server => server),

           Event.new(:kind => :new_app,
                     :created_at => Time.now,
                     :app => App.new(:name => "Airbnb for toothbrushes",
                                     :platforms => "Ruby",
                                     :last_synced_at => 2.seconds.from_now,
                                     :server => server)
                    ),
           Event.new(:kind => :new_app,
                     :created_at => Time.now,
                     :app => App.new(:name => "Uber for dogs",
                                     :platforms => "Node",
                                     :last_synced_at => 2.seconds.from_now,
                                     :server => server)
                    )
          ]
    arr.reverse
  end
end
