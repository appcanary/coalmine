class CanaryClient
  def initialize(url, o={})
    opts = {}.merge(o)
    @user_token = opts[:user_token]
    @agent_token = opts[:agent_token]
    @conn = Faraday.new(url: url) do |faraday|
      faraday.request :url_encoded
      faraday.response :json
      faraday.adapter Faraday.default_adapter # NetHttp
    end
  end

  # TODO: add pagination to collection methods

  # Status

  def status
    get('status')
  end

  # Vulnerabilities

  def vulnerabilities
    get('vulnerabilities')
  end

  def vulnerability(uuid)
    get("vulnerabilities/#{uuid}")
  end

  # Servers

  def servers
    get('servers', token: @user_token)
  end

  def server(uuid)
    get("servers/#{uuid}", token: @user_token)
  end

  def server_apps(uuid)
    get("servers/#{uuid}/apps", token: @user_token)
  end

  def server_app(server_uuid, app_uuid)
    get("servers/#{server_uuid}/apps/#{app_uuid}", token: @user_token)
  end

  def server_app_vulnerabilities(server_uuid, app_uuid)
    get("servers/#{server_uuid}/apps/#{app_uuid}/vulnerabilities", token: @user_token)
  end

  def server_vulnerabilities(server_uuid)
    get("servers/#{server_uuid}/vulnerabilities", token: @user_token)
  end

  # Artifacts

  def artifacts
    get('artifacts')
  end

  def artifact(uuid)
    get("artifacts/#{uuid}")
  end

  def artifact_kinds
    get('artifacts/kinds')
  end

  def artifact_vulnerabilities(uuid)
    get("artifacts/#{uuid}/vulnerabilities")
  end

  # Users

  def me
    get('users/me', token: @user_token)
  end

  def my_vulnerabilities
    get('users/me/vulnerabilities', token: @user_token)
  end

  def add_user(data)
    post('users', data: data)
  end

  # Agents

  def add_agent_server(data)
    post('agent/servers', data: data, token: @agent_token)
  end

  def update_agent_server(server_uuid, data)
    put("agent/servers/#{server_uuid}", data: data, token: @agent_token)
  end

  def add_agent_heartbeat(server_uuid, data)
    post("agent/heartbeat/#{server_uuid}", data: data, token: @agent_token)
  end

  # DELETE THIS
  def self.try
    c = CanaryClient.new('http://localhost:3000/v1',
                         user_token: 'ohicvf2knu0jt9u6p180vpnu6u7vk3151g0794po2mbfrgc0u4f',
                         agent_token: 'p28tdt94c6fu8l3hscq2gq16uef6fncrud4s6smkfh7qfk1sam7')
    require 'base64'
    s = c.servers.first
    a = c.server_apps(s['uuid']).first
    c.vulnerabilities
  end

  protected

  def get(url, o={})
    opts = {}.merge(o)
    @conn.get(url) do |req|
      if opts[:token]
        req.headers['Authorization'] = 'Token ' + opts[:token]
      end
    end.body
  end

  def put(url, o={})
    upsert(:put, url, o)
  end

  def post(url, o={})
    upsert(:post, url, o)
  end

  def upsert(method, url, o={})
    opts = {}.merge(o)
    @conn.method(method).call(url) do |req|
      if opts[:token]
        req.headers['Authorization'] = 'Token ' + opts[:token]
      end
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON.generate(opts[:data])
    end.on_complete do |res|
      puts res.to_yaml
    end.body
  end
end
