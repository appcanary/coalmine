class RubysecAdvisoryAdapter 
  attr_accessor :gem, :framework, :platform, 
    :cve, :url, :title, 
    :date, :description, :cvss_v2, 
    :cvss_v3, :unaffected_versions, :patched_versions

  include ActiveModel::Model
  
end
