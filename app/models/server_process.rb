class ServerProcess < ActiveRecord::Base
  belongs_to :agent_server
  has_many :server_process_libraries, :dependent => :destroy
  has_many :process_libraries, :through => :server_process_libraries

  def update_libs(libs)
    libs.each do |lib|
      proc_lib = ProcessLibrary.find_or_create_by!(path: lib[:path], package: lib[:package])
      self.process_libraries << proc_lib
      self.save!
      # this should now exist
      spl = server_process_libraries.find_by!(:proc_lib_id => proc_lib.id)
      spl.outdated = lib[:outdated]
      spl.save!
    end
  end
end
