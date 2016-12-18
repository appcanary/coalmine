class RubysecAdvisory < ActiveRecord::Base
  has_secure_token :ident

  ATTRIBUTES = ["gem",
                "date",
                "url",
                "cve",
                "title",
                "description",
                "cvss_v2",
                "cvss_v3",
                "unaffected_versions",
                "patched_versions",
                "related"]
  def generate_yaml
    self.attributes.slice(*ATTRIBUTES).tap do |hsh|
      ["unaffected_versions", "patched_versions", "related"].each do |k|
        hsh[k] = hsh[k].lines.map(&:strip)
      end
    end.compact.to_yaml
  end
end
