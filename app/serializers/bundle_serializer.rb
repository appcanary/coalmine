class BundleSerializer < ActiveModel::Serializer
  type "monitors"
  attributes :name, :vulnerable, :updated_at, :created_at
  def vulnerable
    object.vulnerable?
  end
end
