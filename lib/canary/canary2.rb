require 'faraday_middleware'

class Canary2
  delegate :request, :to => :client
  def client
    @client ||= Client.new(Rails.configuration.canary.uri)
  end

  def initialize(user_token = "")
    @user_token = user_token
  end

  def get(url, opts={})
    perform_request(:get, url, opts)
  end

  def put(url, opts={})
    perform_request(:put, url, opts)
  end

  def post(url, opts={})
    perform_request(:post, url, opts)
  end

  def delete(url, opts={})
    perform_request(:delete, url, opts)
  end

  def perform_request(verb, url, opts = {})
    Response.new(request(verb, url, {:token => @user_token, :data => opts}))
  end


  class Client
    def initialize(url, opts={})
      options = {}.merge(opts)
      @conn = Faraday.new(url: url) do |faraday|
        faraday.request :url_encoded
        faraday.response :json
        faraday.adapter Faraday.default_adapter # NetHttp
      end
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
      end
    end
  end

  class CanaryError < StandardError; 
    attr_accessor :status, :body
    def initialize(status, msg)
      @status = status
      @body = msg
      super("#{status}: #{msg}")
    end
  end

  class ClientError < CanaryError; end
  class ServerError < CanaryError; end
  class NotFoundError < ClientError; end
  class UnauthorizedError < ClientError; end

  class Response
    delegate :headers, :status, :body, :to => :faraday
    delegate :keys, :each, :map, :reduce, :to => :body
    attr_accessor :faraday

    def initialize(response)
      @faraday = response
      case status
      when 401
        raise UnauthorizedError.new(status, body)
      when 404
        raise NotFoundError.new(status, body)
      when 400..499
        raise ClientError.new(status, body)
      when 500..599
        raise ServerError.new(status, body)
      end
    end

    def [](key)
      body[key]
    end
  end
end


