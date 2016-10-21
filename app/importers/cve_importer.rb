require 'open-uri'
require 'zlib'
class CveImporter < AdvisoryImporter
  SOURCE = "cve-importer"
  PLATFORM = Platforms::None
  CVE_URL = "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-Modified.xml.gz"
  FIRST_IMPORT_URLS = ["https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2002.xml.gz",
                       "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2003.xml.gz",
                       "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2004.xml.gz",
                       "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2005.xml.gz",
                       "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2006.xml.gz",
                       "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2007.xml.gz",
                       "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2008.xml.gz",
                       "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2009.xml.gz",
                       "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2010.xml.gz",
                       "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2011.xml.gz",
                       "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2012.xml.gz",
                       "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2013.xml.gz",
                       "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2014.xml.gz",
                       "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2015.xml.gz",
                       "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2016.xml.gz",
                       #TODO: add this in 2017 "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-2017.xml.gz",
                       "https://static.nvd.nist.gov/feeds/xml/cve/nvdcve-2.0-Recent.xml.gz",]
  LOCAL_PATH = "tmp/importers/cve"


  def self.first_import!
    # I don't love putting this here :S
    FIRST_IMPORT_URLS.each do |url|
      CveImporter.new(url).import!
    end
  end

  def initialize(cve_url = nil)
    @cve_url = cve_url || CVE_URL
  end

  # This parser comes from https://github.com/fidius/cvedb/blob/71cda64b605058721f5c5816dd3296a273a0a3a3/lib/cveparser/parser_model.rb

  def fetch_advisories
    doc = open(@cve_url) do |f|
      gz = Zlib::GzipReader.new(f)
      Nokogiri::XML(gz.read)
    end
    doc.css('nvd > entry')
  end

  def parse(entry)
    CveAdapter.new({
      "cve" => entry.attributes['id'].value,
      "vulnerable_configurations" => vulnerable_configurations(entry),
      "cvss" => cvss(entry),
      "vulnerable_software" => vulnerable_software(entry),
      "published_datetime" => child_value(entry, 'vuln|published-datetime'),
      "last_modified_datetime" => child_value(entry, 'vuln|last-modified-datetime'),
      "cwe" => cwe(entry),
      "summary" => child_value(entry, 'vuln|summary'),
      "references" => references(entry),
    }, entry)
  end

  private
  # Return CWE number for given CVE-Entry
  def cwe entry
    cwe = entry.at_css('vuln|cwe')
    cwe.attributes['id'].value if cwe
  end
  
  # Returns an array of all references which belong to the given CVE-Entry 
  def references entry
    ref_array = []
    entry.css('vuln|references').each do |references|
      ref_params = {}
      ref_params[:source] = child_value(references, 'vuln|source')
      ref = references.at_css('vuln|reference')
      ref_params[:link] = ref.attributes['href'].value if ref
      ref_params[:name] = child_value(references, 'vuln|reference')
      ref_array << ref_params
    end
    ref_array
  end
  
  # Returns an array of all vulnerable products which belong to the given CVE-Entry
  def vulnerable_software entry
    vuln_products = []
    entry.css('vuln|vulnerable-software-list > vuln|product').each do |product|
      vuln_products << product.children.to_s if product
    end
    vuln_products
  end
  
  # Returns the CVSS-Data from the given CVE-Entry
  def cvss entry
    
    metrics = entry.css('vuln|cvss > cvss|base_metrics')
    unless metrics.empty?
      cvss_params = {}
      {
        :score                  => 'score',
        :source                 => 'source',
        :access_vector          => 'access-vector',
        :authentication         => 'authentication',
        :access_complexity      => 'access-complexity',
        :confidentiality_impact => 'confidentiality-impact',
        :integrity_impact       => 'integrity-impact',
        :availability_impact    => 'availability-impact',
        :generated_on_datetime  => 'generated-on-datetime'
        
      }.each_pair do |hash_key, xml_name|
        elem = metrics.at_css("cvss|#{xml_name}")
        value = elem ? elem.children.to_s : nil
        cvss_params[hash_key] = value
      end
      cvss_params
    end
  end
  
  # Returns an array of all vulnerable configurations which belong to the given CVE-Entry
  def vulnerable_configurations entry
    v_confs = []
    entry.css('vuln|vulnerable-configuration > cpe-lang|logical-test'+
              ' > cpe-lang|fact-ref').each do |conf|
      v_confs << conf.attributes['name'].value
    end
    v_confs
  end
  
  # Helper method to retrieve the value of a child node in a XML file
  def child_value(node, xml)
    val = node.at_css(xml)
    val.children.to_s if val
  end

end

