class FixReleasesInMonitors < ActiveRecord::Migration
  def up
    # It's possible that we have dupe packages if two monitors have the same major release BUT none of prod data has this so we're safe if we run this soon.
    # And otherwise, we have package merge code
    Package.where(:platform => Platforms::Alpine).find_each do |p|
      p.release.gsub!(/(\d+\.\d+)\.\d+/,'\1')
      p.save
    end

    # Logs and vulnerable packages need to be recomputed, they will be when the importer changes all the vulns in the same PR
    Bundle.where(:platform => Platforms::Alpine).find_each do |b|
      b.release.gsub!(/(\d+\.\d+)\.\d+/,'\1')
      b.save
    end

  end
  def down
  end
end
