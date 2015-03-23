class Timeline
  def self.for(user)
    server = Server.new(:name => "droplet37a")
    airbnb = App.new(:name => "Airbnb for toothbrushes",
                     :platforms => "Ruby",
                     :last_synced_at => 2.seconds.from_now,
                     :server => server)

    uber = App.new(:name => "Uber for dogs",
                   :platforms => "Node",
                   :last_synced_at => 2.seconds.from_now,
                   :server => server)


    arr = [
      new_server(server),
      new_app(airbnb),
      new_app(uber),
      new_vuln(Vuln.new, server, uber)
    ]
    arr.reverse
  end

  private 
  class << self
    def new_server(server, opt = {})
      opt[:kind] = :new_server
      opt[:server] = server
      new_event(opt)
    end

    def new_app(app, opt = {})
      opt[:kind] = :new_app
      opt[:app] = app

      new_event(opt)
    end

    def new_vuln(vuln, server, app, opt = {})
      opt[:kind] = :vuln
      opt[:vuln] = vuln
      opt[:app] = app
      opt[:server] = server
      new_event(opt)
    end

    def new_event(opt = {})
      default = {
        :created_at => Time.now
      }

      Event.new(default.merge(opt))
    end
  end
end
