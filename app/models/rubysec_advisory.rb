class RubysecAdvisory < ActiveRecord::Base
  has_secure_token :ident

  def generate_yaml
    [:gem, :framework, :platform,
     :date, :url, :cve, :title, :description,
     :cvss_v2, :cvss_v3, :unaffected_versions, 
     :patched_versions, :related].reduce({}) { |acc, sym|

       if (val = self.send(sym)).present?
         if [:unaffected_versions, :patched_versions, :related].include?(sym)
           val = val.lines.map(&:strip)
         end

         acc[sym.to_s] = val
       end

       acc

     }.to_yaml
  end
end
