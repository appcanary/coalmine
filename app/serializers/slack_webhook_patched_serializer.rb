class SlackWebhookPatchedSerializer < ActiveModel::Serializer
  attributes :text

  def text
    "hello"
  end
end
