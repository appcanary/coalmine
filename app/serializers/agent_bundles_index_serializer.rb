# couldn't be arsed to figure out how to configure this
# such that it doesn't include every vuln and package id 
# when rendering the index view.
class AgentBundlesIndexSerializer < ActiveModel::Serializer
  type :monitors
  attributes :name, :path, :vulnerable, :created_at

  def vulnerable
    object.vulnerable_at_all?
  end
end

