class FixOldIsItVulnResults < ActiveRecord::Migration
  def change
    # 2016-08-05 this was preventing future migrations from
    # running, maybe cos we've changed what a 'Vulnerability' is
    # i could try to figure this out but this data got fixed already
    # so screw it, commented it out it is.

    # Artifact; ArtifactVersion; Vulnerability;
    # ActiveRecord::Migration.verbose = false
    # IsItVulnResult.find_each(:batch_size => 100) do |iivr|
    #   begin
    #     iivr.result.try(:first).try(:name)
    #   rescue Exception => e
    #     yaml = iivr.attributes_before_type_cast["result"].gsub(/!ruby.*/, "deprecated: true")

    #     new_result = YAML.load(yaml).map {|y| ArtifactVersion.parse(y) }

    #     new_result = YAML.dump(new_result);
    #     updates = ActiveRecord::Base.send(:sanitize_sql_array, ["result = ?", new_result]);
    #     IsItVulnResult.connection.update("UPDATE is_it_vuln_results SET #{updates} WHERE is_it_vuln_results.id = #{iivr.id}")
    #   end
    # end
  end
end
