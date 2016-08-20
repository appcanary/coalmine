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

  def self.sample_package_list
    @sample_packages ||= 
      [{:version=>"3.2.19", :name=>"actionpack"},
       {:version=>"3.2.19", :name=>"activesupport"},
       {:version=>"2.2.1", :name=>"jquery-rails"},
       {:version=>"1.5.11", :name=>"nokogiri"},
       {:version=>"1.4.5", :name=>"rack"},
       {:version=>"2.2.6", :name=>"twitter-bootstrap-rails"}].map { |pkg|
         Parcel::Rubygem.new(pkg)
       }
  end
end
