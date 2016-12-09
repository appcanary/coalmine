class CreateVulnderabilityIndex < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE MATERIALIZED VIEW vulnerability_search_index AS
SELECT vulnerabilities.id as vulnerability_id,
       (to_tsvector(title)
       || to_tsvector(coalesce(description, ''))
       || to_tsvector(array_to_string(reference_ids, ' ', ''))
       || to_tsvector(vulnerabilities.platform)
       || to_tsvector(coalesce(string_agg(vulnerable_dependencies.package_name, ' '), '')))::tsvector as document
FROM "vulnerabilities" INNER JOIN "vulnerable_dependencies" ON "vulnerable_dependencies"."vulnerability_id" = "vulnerabilities"."id"
GROUP BY vulnerabilities.id
SQL
    add_index(:vulnerability_search_index, :document, using: 'gin')
    add_index(:vulnerability_search_index, :vulnerability_id, unique: true)
  end

  def down
    execute "DROP MATERIALIZED VIEW vulnerability_search_index"
  end
end
