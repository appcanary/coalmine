class ApiBase < OpenStruct
  extend ActiveModel::Naming

  def initialize(attr = {}, client = nil)
    super(attr)
    self.attributes = attr

    # if the client has a user token,
    # we either keep it around or we reinit
    # the client every time. Let's keep it?
    self.__client = client
  end

  def self.parse(hsh, client = nil)
    self.new(sanitize_param_keys(hsh), client)
  end

  # dashes are not valid method names
  # let's convert dashes to underscores
  
  # base assumption is OpenStruct won't let
  # you assign values that are dangerous,
  # which was briefly tested in console
  def self.sanitize_param_keys(params = {})
    new_params = {}
    params.each_pair do |k, v|
      key = k.to_s.tr("-", "_")
      new_params[key] = v
    end
    new_params
  end

  def to_param
    uuid
  end

  def if_enum(obj)
    obj || []
  end

  def self.obtain_clientv2(user=nil, opt = {})
    CanaryClient.new(user.try(:agent_token), opt.merge(:prefix => "/v2"))
  end

  def self.build_rl(endpoint, path = nil, query = {})
    str = [endpoint, path].select(&:present?).join("/")
    [str, query.to_query].select(&:present?).join("?")
  end

  def self.validate_attr!(body)
    if body["errors"].present?
      raise CanaryApiError.new(body["errors"])
    else
      if body["data"].blank?
        raise CanaryApiError.new("Missing data key in #{body}")
      end
    end
    true
  end

  class CanaryApiError < StandardError; end;

end
