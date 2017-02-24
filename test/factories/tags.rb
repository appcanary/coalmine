# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  tag        :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tags_on_account_id          (account_id)
#  index_tags_on_account_id_and_tag  (account_id,tag) UNIQUE
#  index_tags_on_tag                 (tag)
#

FactoryGirl.define do
  factory :tag do
    account
    tag "MyText"
  end

end
