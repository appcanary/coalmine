require 'httpclient'
require 'json'

class CanaryClient

  def initialize
  end

  def request
    @request ||= HTTPClient.new
  end

  def root
    'http://localhost:3000/v1'
  end

  def url(path)
    root + path
  end

  def status
    get('/status')
  end

  def vulnerability(uuid)
    get("/vulnerabilities/#{uuid}")
  end

  protected

  def get(path)
    results = JSON.parse(request.get(url(path)).body)
    ruby_results = convert_hash_keys(results)
    RecursiveOpenStruct.new(ruby_results,
                            :recurse_over_arrays => true)
  end

  def underscore_key(k)
    k.to_s.underscore.to_sym
  end

  def convert_hash_keys(value)
    case value
    when Array
      value.map { |v| convert_hash_keys(v) }
      # or `value.map(&method(:convert_hash_keys))`
    when Hash
      Hash[value.map { |k, v| [underscore_key(k), convert_hash_keys(v)] }]
    else
      value
    end
  end
end
