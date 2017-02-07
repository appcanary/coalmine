# == Schema Information
#
# Table name: process_libraries
#
#  id              :integer          not null, primary key
#  path            :string
#  modified        :datetime
#  package_name    :string
#  package_version :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ProcessLibrary < ActiveRecord::Base
  attr_accessor :outdated

  has_many :server_process_libraries
  has_many :server_processes, :through => :server_process_libraries
end
