class Advisory < ActiveRecord::Base
  has_many :vulnerabilities
end
