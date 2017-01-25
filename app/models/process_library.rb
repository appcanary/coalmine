class ProcessLibrary < ActiveRecord::Base
  attr_accessor :outdated

  has_many :server_process_libraries
  has_many :server_processes, :through => :server_process_libraries
end
