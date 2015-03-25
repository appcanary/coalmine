class Event
  include Mocker

  mock_attr(:kind) { [:new_server, :new_app, :new_vuln].shuffle.first }

  mock_attr(:created_at) { rand(1..10).hours.ago }

  mock_attr(:app) { App.new }
  mock_attr(:vuln) { Vuln.new }
  mock_attr(:server) { Server.new }

  mock_attr(:message) { "You added a new app!" }
  mock_attr(:tour_enter) { nil }
  mock_attr(:tour_exit) { 1000 }
  

  def server
    @server ||= Server.new
  end

  def server?
    kind == :new_server
  end

  def app
    @app ||= App.new
  end

  def app?
    kind == :new_app
  end

  def avatar
    if app?
      obj = app
    else
      obj = server
    end

    obj.avatar
  end

end

