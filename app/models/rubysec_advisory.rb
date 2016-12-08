class RubysecAdvisory < ActiveRecord::Base
  has_secure_token :ident

  def generate_yaml
    [:gem, :framework, :platform,
     :date, :url, :cve, :title, :description,
     :cvss_v2, :cvss_v3, :unaffected_versions, 
     :patched_versions].reduce({}) { |acc, sym|

      if (val = self.send(sym)).present?
        acc[sym.to_s] = val
      end
      acc
    }.to_yaml
  end
end
