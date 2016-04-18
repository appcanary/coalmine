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

end
