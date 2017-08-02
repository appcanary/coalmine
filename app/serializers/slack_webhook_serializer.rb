class SlackWebhookSerializer < ActiveModel::Serializer
  attributes :text

  def text
    "hello"
  end

end
