# == Schema Information
#
# Table name: is_it_vuln_results
#
#  id          :integer          not null, primary key
#  ident       :string           not null
#  result      :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  pre_user_id :integer
#
# Indexes
#
#  index_is_it_vuln_results_on_ident        (ident)
#  index_is_it_vuln_results_on_pre_user_id  (pre_user_id)
#

class IsItVulnResult < ActiveRecord::Base
  before_create do 
    self.ident = SecureRandom.hex(16)
  end

  serialize :result

end
