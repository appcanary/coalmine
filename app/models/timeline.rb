class Timeline
  def self.for(user)
    server = Server.fake_servers[0]
    airbnb = App.fake_apps[0]

    uber = App.fake_apps[1]

    vuln, vuln2 = Vuln.fake_vulns

    arr = [
      new_server(server, :tour_enter => 1),
      new_app(airbnb, :tour_enter => 2),
      new_app(uber, :tour_enter => 2),
      new_vuln(vuln, server, airbnb, :tour_enter => 3, :tour_exit => 4),
      new_not_vuln(vuln, server, airbnb, :kind => :not_vuln_app, :tour_enter => 4),
      new_allclear_app(airbnb, :tour_enter => 4, :tour_exit => 5),

      # heartbleed
      new_vuln(vuln2, server, airbnb, :app2 => uber, :tour_enter => 5, :tour_exit => 6),
      new_not_vuln(vuln2, server, airbnb, :app2 => uber, :kind => :not_vuln_server, :tour_enter => 6),
      new_allclear_server(server, :tour_enter => 6),
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

    def new_not_vuln(vuln, server, app, opt = {})
      opt.merge!({#:kind => :not_vuln,
                  :vuln => vuln,
                  :server => server,
                  :app => app})
      new_event(opt)
    end

    def new_event(opt = {})
      default = {
        :created_at => Time.now
      }

      Event.new(default.merge(opt))
    end

    def new_allclear_server(server, opt = {})
      opt.merge!({:kind => :allclear_server,
                  :server => server})
      new_event(opt)
    end

    def new_allclear_app(app, opt = {})
      opt.merge!({:kind => :allclear_app,
                  :app => app})
      new_event(opt)
    end

  end
end
