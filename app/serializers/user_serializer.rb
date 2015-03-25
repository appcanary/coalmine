class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :onboarded, :tour_tick
end
