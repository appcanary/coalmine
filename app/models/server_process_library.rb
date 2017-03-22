# == Schema Information
#
# Table name: server_process_libraries
#
#  id                 :integer          not null, primary key
#  server_process_id  :integer          not null
#  process_library_id :integer          not null
#  outdated           :boolean          default("false")
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_server_process_libraries_on_process_library_id  (process_library_id)
#  index_server_process_libraries_on_server_process_id   (server_process_id)
#

class ServerProcessLibrary < ActiveRecord::Base
  belongs_to :server_process
  belongs_to :process_library
end
