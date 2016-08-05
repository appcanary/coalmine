# == Schema Information
#
# Table name: pre_users
#
#  id                 :integer          not null, primary key
#  email              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  preferred_platform :string
#  from_isitvuln      :boolean          default("false")
#

class PreUser < ActiveRecord::Base
  PLATFORMS = [
    "Python",
    "Node",
    "Java",
    "PHP",
    "Go",
    "Other"]
end
