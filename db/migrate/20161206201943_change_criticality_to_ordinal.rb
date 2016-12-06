class ChangeCriticalityToOrdinal < ActiveRecord::Migration
  def up
    change_column :vulnerabilities, :criticality, "integer USING (CASE criticality WHEN 'unknown' THEN 0::integer WHEN 'negligible' THEN 10::integer WHEN 'low' THEN 20::integer WHEN 'medium' THEN 30::integer WHEN 'high' THEN 40::integer WHEN 'critical' THEN 50::integer ELSE 0::integer END)", null: false, default: 0
    change_column :advisories, :criticality, "integer USING (CASE criticality WHEN 'unknown' THEN 0::integer WHEN 'negligible' THEN 10::integer WHEN 'low' THEN 20::integer WHEN 'medium' THEN 30::integer WHEN 'high' THEN 40::integer WHEN 'critical' THEN 50::integer ELSE 0::integer END)", null: false, default: 0
  end
  def down
    change_column :vulnerabilities, :criticality, "varchar USING (CASE criticality WHEN 0 THEN 'unknown'::varchar WHEN 10 THEN 'negligible'::varchar WHEN 20 THEN 'low'::varchar WHEN 30 THEN 'medium'::varchar WHEN 40 THEN 'high'::varchar WHEN 50 THEN 'critical'::varchar ELSE 'unknown'::varchar END)"
    change_column :advisories, :criticality, "varchar USING (CASE criticality WHEN 0 THEN 'unknown'::varchar WHEN 10 THEN 'negligible'::varchar WHEN 20 THEN 'low'::varchar WHEN 30 THEN 'medium'::varchar WHEN 40 THEN 'high'::varchar WHEN 50 THEN 'critical'::varchar ELSE 'unknown'::varchar END)"
  end
end
