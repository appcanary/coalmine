class BundleSerializer < ActiveModel::Serializer
  attributes :name, :vulnerable, :updated_at, :created_at
  def vulnerable
    object.vulnerable?
  end
end
