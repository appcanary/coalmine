class FixOldIsItVulnResults < ActiveRecord::Migration
  def change
    Artifact; ArtifactVersion; Vulnerability;
    ActiveRecord::Migration.verbose = false
    IsItVulnResult.find_each(:batch_size => 100) do |iivr|
      begin
        iivr.result.try(:first).try(:name)
      rescue Exception => e
        yaml = iivr.attributes_before_type_cast["result"].gsub(/!ruby.*/, "deprecated: true")
        new_result = YAML.load(yaml).map {|y| ArtifactVersion.parse(y) }
        iivr.result = new_result
        iivr.save!
      end
    end
  end
end
