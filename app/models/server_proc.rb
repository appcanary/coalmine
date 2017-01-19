class ServerProc < ActiveRecord::Base
  belongs_to :agent_server
  has_many :server_proc_libs, :dependent => :destroy
  has_many :proc_libs, :through => :server_proc_libs, :class_name => ProcLib

  def update_libs(libs)
    libs.each do |lib|
      proc_lib = ProcLib.find_or_create_by!(path: lib[:path], package: lib[:package])
      self.proc_libs << proc_lib
      self.save!
      # this should now exist
      spl = server_proc_libs.find_by!(:proc_lib_id => proc_lib.id)
      spl.outdated = lib[:outdated]
      spl.save!
    end
  end
end
