class Item
  include Mocker

  mock_attr(:kind) { [:new_server, :new_app, :new_vuln].shuffle.first }

  mock_attr(:created_at) { rand(1..10).hours.ago }

  mock_attr(:app) { App.new }
  mock_attr(:vuln) { Vuln.new }

  mock_attr(:message) { "You added a new app!" }

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
