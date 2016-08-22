namespace :db do
  desc "move away from old api iivr"
  task :one_time_migrate_iivr => :environment do

    class ArtifactVersion < OpenStruct; 
      def name
        attributes["name"] || artifact.try(:first).try(:[], "name")
      end
    end

    IsItVulnResult.find_each do |iivr|
      begin
        next if iivr.result.first.is_a? Parcel
        parcels = iivr.result.map { |av|

          hsh = {name: av.name,
                 version: av.number}

          Parcel::Rubygem.new(hsh)
        }

      new_result = YAML.dump(parcels);
      updates = ActiveRecord::Base.send(:sanitize_sql_array, ["result = ?", new_result]);
      IsItVulnResult.connection.update("UPDATE is_it_vuln_results SET #{updates} WHERE is_it_vuln_results.id = #{iivr.id}")

      rescue Exception => e
      end
    end

  end
end

