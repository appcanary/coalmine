require 'fileutils'
require 'open3'

class BzrHandler
  attr_accessor :klass_name, :repo_url, :local_path
  def initialize(klass, url, path)
    self.klass_name = klass.name
    self.repo_url = url
    self.local_path = path
  end

  def fetch_and_update_repo!
    if File.exists?(local_path)
      output, process = Open3.capture2e("cd #{local_path} && bzr pull")
      unless process.success?

        # sometimes bzr gets stuck?
        # it's kind of annoying
        if output =~ /Unable to obtain lock/
          # sometimes overlapping processes will cause
          # bzr to be stuck. if that's us, force a lock
          # break and try again later
          output, process = Open3.capture2e("cd #{local_path} && bzr break-lock --force")
          unless process.success?
            raise "#{klass_name} - something went wrong breaking lock: #{output}"
          end
        elsif output =~ /Not a branch:/
          # sometimes the worker might die mid pull
          # and leaves the checkout mid state
          # and i don't think this error is recoverable
          # so let's try again later
          FileUtils.rm_rf(local_path)
        else
          raise "#{klass_name} - something went wrong pulling: #{output}"
        end
      end
    else
      # bzr will fail if folder already exists, so no mkdir p
      output, process = Open3.capture2e("bzr branch #{repo_url} #{local_path}")
      unless process.success?
        raise "#{klass_name} - something went wrong cloning: #{output}"
      end
    end
  end
end
