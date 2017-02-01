class ServerProcessPresenter
  attr_reader :server_process

  delegate :id, :name, :pid, to: :server_process

  def initialize(server_process)
    @server_process = server_process
  end

  def process_libraries
    server_process.server_process_libraries.order(outdated: "desc").map do |spl|
      spl.process_library.tap do |pl|
        pl.outdated = spl.outdated
      end
    end
  end

  def outdated?
    server_process.process_libraries
      .where(server_process_libraries: { outdated: true })
      .any?
  end
end
