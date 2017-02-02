class AgentServerManager
  attr_reader :server

  def initialize(server)
    @server = server
  end

  def update_processes(system_state)
    libraries = system_state[:libraries]
    processes = system_state[:processes]

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
    proc_keys = [:pid, :started, :name]
    attrs = proc.slice(*proc_keys).permit(*proc_keys)
    server.server_processes.find_or_initialize_by(attrs)
  end

  def find_or_create_process_libraries(process, libraries)
    spector_libraries = process[:libraries].try(:map) do |lib|
      libraries[lib[:library_path]].tap do |system_lib|
        system_lib[:outdated] = lib[:outdated]
      end
    end

    return [] if spector_libraries.blank?

    lib_keys = [:path, :package_name, :package_version]
    spector_libraries.map do |lib|
      attrs = lib.slice(*lib_keys).permit(*lib_keys)

      ProcessLibrary.find_or_create_by!(attrs).tap do |pl|
        pl.outdated = lib[:outdated]
        pl.modified = lib[:modified]
      end
    end
  end
end
