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

    # TODO: use upsert, rename upsert something else
    def get(url, opts={})
      request(:get, url, opts)
    end

    # TODO: untested
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

  class Base
    include TrackAttributes
    def initialize(params={})
      params.each do |attr, value|
        setter = attr.tr("-", "_")
        self.public_send("#{setter}=", value)
      end if params
    end

    def attributes
      Hash[attr_accessors.map { |k| [k, send(k)] }]
    end
  end

  class Server < Base
    attr_accessor :apps, :last_heartbeat, :ip, :name, :hostname, :uname, :id, :uuid
  end

  class Vuln < Base
    attr_accessor :description, :osvdb, :reported_at, :cve, :title, :id, 
      :artifact, :uuid, :versions, :unaffected_versions, :patched_versions, :criticality
  end

  class App < Base
    attr_accessor :id, :name, :path, :uuid, :artifact_versions, :vulnerable_to
  end

  class User < Base
    attr_accessor :id, :name, :email, :servers, :web_token, :agent_token
  end

  class Artifact < Base
    attr_accessor :description, :mailinglist_uri, :source_uri, :name, :id, :unknown_origin, :uri, :uuid, :versions, :authors
  end

  # TODO: add pagination to collection methods

  def status
    get('status')
  end

  # Vulnerabilities

  def vulnerabilities
    wrap Vuln, get('vulnerabilities')['vulnerabilities']
  end

  def vulnerability(uuid)
    wrap Vuln, get("vulnerabilities/#{uuid}")
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
    wrap Vuln, get("servers/#{server_uuid}/apps/#{app_uuid}/vulnerabilities", token: @user_token)
  end

  def server_vulnerabilities(server_uuid)
    wrap Vuln, get("servers/#{server_uuid}/vulnerabilities", token: @user_token)
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
    wrap Vuln, get("artifacts/#{uuid}/vulnerabilities")
  end

  # Users

  def me
    wrap User, get('users/me', token: @user_token)
  end

  def my_vulnerabilities
    wrap Vuln, get('users/me/vulnerabilities', token: @user_token)
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
    if col.is_a? Array
      col.map { |attr| klass.new(attr) }
    else
      klass.new(col)
    end
  end

end
