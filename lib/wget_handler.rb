require 'open3'

class WgetHandler
  attr_accessor :klass_name, :mirror_url, :local_path, :mirror_pattern
  def initialize(klass, url, path, pattern)
    self.klass_name = klass.name
    self.mirror_url = url
    self.mirror_pattern = pattern
    self.local_path = path
  end

  def mirror!
    # no host directories, no parent, timestamping recursive
    output, process = Open3.capture2e("wget -nH -np -N -r -A \"#{mirror_pattern}\"  -P #{local_path} #{mirror_url}")
    unless process.success?
      raise "#{klass_name} - something when wrong mirroring: #{output}"
    end
  end
end
