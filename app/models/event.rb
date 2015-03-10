class Event
  include Mocker

  mock_attr(:kind) { [:new_server, :new_app].shuffle.first }

  mock_attr(:created_at) { rand(1..10).hours.ago }

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
