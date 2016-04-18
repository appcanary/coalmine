class App < ApiBase 

  def self.find(user, server_id, id)
    client = Canary2.new(user.token)
    resp = client.get("servers/#{server_id}/apps/#{id}")

    self.parse(resp.body, client)
  end

  def display_name
    name.blank? ? path : name
  end

  def short_path
    path_strs = path.split("/")
    path_strs[0..-2].map(&:first).join("/") + "/" + path_strs[-1]
  end

  def vulnerable?
    self.vulnerable
  end


  def artifact_versions
    if_enum(self.attributes["artifact_versions"]).map do |av|
      ArtifactVersion.parse(av)
    end
  end

  def vulnerable_artifact_versions
     if_enum(self.attributes["vulnerable_artifact_versions"]).map do |av|
      ArtifactVersion.parse(av)
    end
  end

end
