class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :onboard_state
end
