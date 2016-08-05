# == Schema Information
#
# Table name: is_it_vuln_results
#
#  id         :integer          not null, primary key
#  ident      :string           not null
#  result     :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_is_it_vuln_results_on_ident  (ident)
#

class IsItVulnResult < ActiveRecord::Base
  before_create do 
    self.ident = SecureRandom.hex(16)
  end

  serialize :result

end
