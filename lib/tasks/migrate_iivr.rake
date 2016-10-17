namespace :db do
  desc "move away from old api iivr"
  task :one_time_migrate_iivr => :environment do
    Parcel

    class ArtifactVersion < OpenStruct; 
      def name
        if attributes["name"]
          attributes["name"] 
        else
          if artifact.is_a? Hash
            artifact["name"]
          else s = artifact.try(:first)
            if s.is_a? Hash
              s["name"]
            end
          end
        end
      end
    end

    IsItVulnResult.find_each do |iivr|
      begin
        next if iivr.result.nil?
        next if iivr.result.first.is_a? Parcel
        parcels = iivr.result.map { |av|
          next if av.number.nil?
          hsh = {name: av.name,
                 version: av.number}

          Parcel::Rubygem.new(hsh)
        }.compact

        new_result = YAML.dump(parcels);
        updates = ActiveRecord::Base.send(:sanitize_sql_array, ["result = ?", new_result]);
        IsItVulnResult.connection.update("UPDATE is_it_vuln_results SET #{updates} WHERE is_it_vuln_results.id = #{iivr.id}")

      rescue Exception => e
        binding.pry
      end
    end

  end
end

