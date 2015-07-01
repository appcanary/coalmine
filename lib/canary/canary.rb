require 'faraday_middleware'

class Canary
  delegate :get, :put, :post, :to => :client
  def client
    @client ||= Client.new(Rails.configuration.canary.uri)
  end

  def initialize(user_token)
    @user_token = user_token
  end

  class Client
    def initialize(url, opts={})
      options = {}.merge(opts)
      @agent_token = options[:agent_token]
      @conn = Faraday.new(url: url) do |faraday|
        faraday.request :url_encoded
        faraday.response :json
        faraday.adapter Faraday.default_adapter # NetHttp
      end
    end

    def get(url, opts={})
      request(:get, url, opts)
    end

    def put(url, opts={})
      request(:put, url, opts)
    end

    def post(url, opts={})
      request(:post, url, opts)
    end

    def request(method, url, opts={})
      options = {}.merge(opts)
      @conn.method(method).call(url) do |req|
        if options[:token]
          req.headers['Authorization'] = 'Token ' + options[:token]
        end
        if %i(post put).include? method
          req.headers['Content-Type'] = 'application/json'
          req.body = JSON.generate(options[:data])
        end
      end.body
    end
  end

  
  # TODO: add pagination to collection methods

  def status
    get('status')
  end

  # Vulnerabilities

  def vulnerabilities
    wrap Vulnerability, get('vulnerabilities')
  end

  def vulnerability(uuid)
    wrap Vulnerability, get("vulnerabilities/#{uuid}")
  end

  # Servers
  
  def servers
    wrap Server, get('servers', token: @user_token)
  end

  def server(uuid)
    wrap Server, get("servers/#{uuid}", token: @user_token)
  end

  def server_apps(uuid)
    wrap App, get("servers/#{uuid}/apps", token: @user_token)
  end

  def server_app(server_uuid, app_uuid)
    wrap App, get("servers/#{server_uuid}/apps/#{app_uuid}", token: @user_token)
  end

  def server_app_vulnerabilities(server_uuid, app_uuid)
    wrap Vulnerability, get("servers/#{server_uuid}/apps/#{app_uuid}/vulnerabilities", token: @user_token)['vulnerabilities']
  end

  def server_vulnerabilities(server_uuid)
    wrap Vulnerability, get("servers/#{server_uuid}/vulnerabilities", token: @user_token)
  end

  # Artifacts

  def artifacts
    wrap Artifact, get('artifacts')
  end

  def artifact(uuid)
    wrap Artifact, get("artifacts/#{uuid}")
  end

  def artifact_kinds
    get('artifacts/kinds')
  end

  def artifact_vulnerabilities(uuid)
    wrap Vulnerability, get("artifacts/#{uuid}/vulnerabilities")
  end

  # Users

  def me
    get('users/me', token: @user_token)
  end

  def my_vulnerabilities
    wrap Vulnerability, get('users/me/vulnerabilities', token: @user_token)
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

  protected
  def wrap(klass, col)

    # TODO HANDLE CURSORED COLLECTIONS
    # in the meantime, throw away cursor info
    if col.is_a? Hash

      # pass along only the model attr,
      # ditch cursor info
      route_key = klass.model_name.route_key
      if col[route_key]
        # params should be an array of attrs
        params = col[route_key]
      else
        # turns out there was no cursor info, cool
        params = col
      end
    else
      params = col
    end

    if params.is_a? Array
      params.map { |attr| klass.parse(attr, self) }
    else
      klass.parse(params, self)
    end
  end

end
