# == Schema Information
#
# Table name: advisories
#
#  id            :integer          not null, primary key
#  identifier    :string           not null
#  source        :string           not null
#  platform      :string           not null
#  patched       :jsonb            default("[]"), not null
#  affected      :jsonb            default("[]"), not null
#  unaffected    :jsonb            default("[]"), not null
#  constraints   :jsonb            default("[]"), not null
#  title         :string
#  description   :text
#  criticality   :integer          default("0"), not null
#  source_status :string
#  related       :jsonb            default("[]"), not null
#  remediation   :text
#  reference_ids :string           default("{}"), not null, is an Array
#  osvdb_id      :string
#  usn_id        :string
#  dsa_id        :string
#  rhsa_id       :string
#  cesa_id       :string
#  source_text   :text
#  reported_at   :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  valid_at      :datetime         not null
#  expired_at    :datetime         default("infinity"), not null
#  needs_triage  :jsonb            default("[]"), not null
#  package_names :string           default("{}"), not null, is an Array
#  cvss          :decimal(, )
#
# Indexes
#
#  index_advisories_on_cvss                   (cvss)
#  index_advisories_on_expired_at             (expired_at)
#  index_advisories_on_identifier             (identifier)
#  index_advisories_on_source                 (source)
#  index_advisories_on_source_and_identifier  (source,identifier) UNIQUE
#  index_advisories_on_valid_at               (valid_at)
#

# `constraints` is the column we actually use to compute what packages are
# vulnerable. `patched`, `affected`, and `unaffected` all come from the advisory
# sources, but are used to compute `constraints` by the importers.

class Advisory < ActiveRecord::Base
  extend ArchiveBehaviour::BaseModel
  # Used for the enums in Advisory, Vulnerability, and VulnerabilityArchive
  CRITICALITIES = {
    unknown: 0,
    negligible: 10,
    low: 20,
    medium: 30,
    high: 40,
    critical: 50,
  }

  CRITICALITIES_BY_VALUE = CRITICALITIES.invert

  has_many :advisory_vulnerabilities
  has_many :vulnerabilities, :through => :advisory_vulnerabilities
  has_one :advisory_import_state, :autosave => true, :dependent => :destroy
  validates :advisory_import_state, :presence => true
  
  before_validation do
    unless self.advisory_import_state
      self.build_advisory_import_state
    end
  end

  enum criticality: CRITICALITIES

  scope :most_recent_advisory_for, ->(identifier, source) {
    where(:identifier => identifier, :source => source).order("created_at DESC").limit(1)
  }

  scope :unprocessed, -> {
    joins(:advisory_import_state).where(advisory_import_states: { processed: false })
  }

  scope :unprocessed_or_incomplete, -> {
    joins(:advisory_import_state).
      where("advisory_import_states.processed_count < array_length(advisories.reference_ids, 1)")
  }

  scope :from_rubysec, -> {
    where(:source => RubysecImporter::SOURCE)
  }

  scope :from_cesa, -> {
    where(:source => CesaImporter::SOURCE)
  }

  scope :from_rhsa, -> {
    where(:source => RHSAImporter::SOURCE)
  }

  scope :from_alas, -> {
    where(:source => AlasImporter::SOURCE)
  }

  scope :from_ubuntu, -> {
    where(:source => UbuntuTrackerImporter::SOURCE)
  }

  scope :from_usn, -> {
    where(:source => UsnImporter::SOURCE)
  }

  scope :from_debian, -> {
    where(:source => DebianTrackerImporter::SOURCE)
  }

  scope :from_cve, -> {
    where(:source => CveImporter::SOURCE)
  }

  scope :from_friends_of_php, -> {
    where(:source => FriendsOfPHPImporter::SOURCE)
  }

  scope :from_alpine, -> {
    where(:source => AlpineImporter::SOURCE)
  }

  # AIS gets auto saved, so we skip saving it ourselves here.
  def processed_flag=(flag)
    unless self.advisory_import_state
      self.build_advisory_import_state
    end

    self.advisory_import_state.processed = flag
  end

  def to_vuln_attributes
    valid_attr = Vulnerability.attribute_names
    self.attributes.keep_if { |k, _| valid_attr.include?(k) }
  end

  def to_advisory_attributes
    self.attributes.except("id").merge(:advisory_id => self.id)
  end

  def relevant_attributes
    self.attributes.except("id", "updated_at", "created_at", "valid_at", "expired_at")
  end

  def self.cvss_to_criticality(cvss_score)
    # from cvss v3 rating https://nvd.nist.gov/vuln-metrics/cvss
    case cvss_score
    when 0.0..3.9
      Advisory.criticalities["low"]
    when 4.0..6.9
      Advisory.criticalities["medium"]
    when 7.0..8.9
      Advisory.criticalities["high"]
    when 9.0..10.0
      Advisory.criticalities["critical"]
    else
      Advisory.criticalities["unknown"]
    end
  end
end
