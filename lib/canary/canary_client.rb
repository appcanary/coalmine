require 'faraday_middleware'

class CanaryClient
  def initialize(user_token = "", opts={})
    @options = {}.merge(opts)
    @options[:prefix] ||= "/v1"

    @base_uri = Rails.configuration.canary.uri + @options[:prefix]
    @user_token = user_token
  end

  def get(url, data={})
    perform_request(:get, url, data)
  end

  def put(url, data={})
    perform_request(:put, url, data)
  end

  def post(url, data={})
    perform_request(:post, url, data)
  end

  def delete(url, data={})
    perform_request(:delete, url, data)
  end

  # file is a path
  def post_file(url, file)
    perform_request(:post, url, {:file => Faraday::UploadIO.new(file, "application/octet-stream")}, {"Content-Type" => "multipart/form-data"}, {:multipart => true})
  end

  def put_file(url, file)
    perform_request(:put, url, {:file => Faraday::UploadIO.new(file, "application/octet-stream")}, {"Content-Type" => "multipart/form-data"}, {:multipart => true})
  end


  def perform_request(verb, url, data = {}, headers = {}, config = {})
    client ||= Client.new(@base_uri)
    opts = {:token => @user_token, 
            :data => data, 
            :headers => headers}.merge(config)
    Response.new(client.request(verb, url, opts))
  end


  class Client
    def initialize(base_uri, opts={})
      @base_uri = base_uri
    end

    def request(method, url, opts={})
      options = {}.merge(opts)

      @conn = Faraday.new(url: @base_uri) do |faraday|
        # used solely for sending files.
        if options[:multipart]
          faraday.request :multipart
        end

        faraday.request :url_encoded
        faraday.response :json
        faraday.adapter Faraday.default_adapter # NetHttp
      end

      @conn.method(method).call(url) do |req|
        if options[:token].present?
          req.headers['Authorization'] = 'Token ' + options[:token]
        end

        if options[:headers]
          req.headers.merge!(options[:headers])
        end

        # default to generating json, unless we've overriden
        # the content type elsewhere.
        if %i(post put).include? method
          if req.headers['Content-Type'].blank?
            req.headers['Content-Type'] = 'application/json'
            req.body = JSON.generate(options[:data])
          else
            req.body = options[:data]
          end
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


