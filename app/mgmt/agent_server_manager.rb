class AgentServerManager
  attr_reader :server

  def initialize(server)
    @server = server
  end

  def update_processes(process_map)
    libraries = process_map[:libraries]
    processes = process_map[:processes]

    server.transaction do
      server.server_processes = processes.map do |proc|
        process_libraries = find_or_create_process_libraries(proc, libraries)
        build_server_process(proc).tap do |server_process|
          # server_process.process_libraries = process_libraries
          server_process.server_process_libraries = process_libraries.map do |pl|
            ServerProcessLibrary.new(process_library: pl, outdated: pl.outdated)
          end
        end
      end
      server.save!
    end
  end

  def build_server_process(proc)
    attrs = {
      pid: proc[:pid],
      started: proc[:started],
      name: proc[:name]
    }
    server.server_processes.find_or_initialize_by(attrs)
  end

  def find_or_create_process_libraries(process, libraries)
    spector_libraries = process[:libraries].try(:map) do |lib|
      libraries[lib[:library_index]].tap do |spector_lib|
        spector_lib[:outdated] = lib[:outdated]
      end
    end

    return [] if spector_libraries.blank?

    spector_libraries.map do |lib|
      attrs = {
        path: lib[:path],
        package_name: lib[:package_name],
        package_version: lib[:package_version]
      }

      ProcessLibrary.find_or_create_by!(attrs).tap do |pl|
        pl.outdated = lib[:outdated]
      end
    end
  end
end
