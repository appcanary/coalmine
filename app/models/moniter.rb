class Moniter < ApiBase
  def self.find_all(user)
    client = obtain_clientv2(user)

    resp = client.get("monitors")
    body = resp.body
 
    if body["errors"].nil?
      body["data"].map do |m|
        self.parse(m["attributes"], client)
      end
    else
      raise CanaryApiError.new(body["errors"])
    end
  end

  def self.find(user, id)
    client = obtain_clientv2(user)
    resp = client.get("monitors/#{id}")
    body = resp.body

    if validate_attr!(body)
      self.parse(body["data"]["attributes"])
    end
  end

  def self.create(user, file, environs, name = nil)
    client = obtain_clientv2(user, :multipart => true)

    query = build_rl("monitors", name, environs)
    resp = client.post_file(query, file)
    body = resp.body

    if validate_attr!(body)
      self.parse(body["data"])
    end
  end

  def self.update(user, file, environs, name)
    client = obtain_clientv2(user, :multipart => true)

    query = build_rl("monitors", name, environs)
    resp = client.put_file(query, file)
    body = resp.body

    if validate_attr!(body)
      self.parse(body["data"])
    end
  end

  def self.destroy(user, name)
    client = obtain_clientv2(user)

    query = build_rl("monitors", name)
    resp = client.delete(query)

    if resp.status == 204
      true
    else
      false
    end
  end
end
