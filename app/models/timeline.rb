class Timeline
  def self.for(user)
    server = Server.fake_servers[0]
    airbnb = App.fake_apps[0]

    uber = App.fake_apps[1]

    arr = [
      new_server(server),
      new_app(airbnb),
      new_app(uber),
      new_vuln(Vuln.new, server, airbnb)
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
