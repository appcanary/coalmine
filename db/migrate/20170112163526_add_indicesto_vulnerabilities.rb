class AddIndicestoVulnerabilities < ActiveRecord::Migration
  def change
    add_index :vulnerabilities, [:criticality, :reported_at], order: {criticality: :desc, reported_at: :desc}
  end
end
