require 'msgpack'
class UsnImporter < AdvisoryImporter
  SOURCE = "usn"
  PLATFORM = Platforms::Ubuntu
  PICKLE_URL = "https://usn.ubuntu.com/usn-db/database-all.pickle.bz2"
  LOCAL_PATH = "tmp/importers/usn"

  def initialize(pickle_url = nil)
    @pickle_url = pickle_url || PICKLE_URL
    @local_path = LOCAL_PATH
    @pickle_bz2_path = File.join(@local_path, "database-all.pickle.bz2")
    @msgpack_path = File.join(@local_path, "database-all.msgpack")
    FileUtils.mkdir_p(@local_path)
  end

  def update_local_store!
    # not much point continuing really ¯\_(ツ)_/¯
    raise "No python interpreter found!" unless find_python
    
    pickle = open(@pickle_url)
    IO.copy_stream(pickle, @pickle_bz2_path)
    # convert the pickle to a msgpack
    `#{find_python} lib/unpickle.py #{@pickle_bz2_path}`
  end

  def fetch_advisories
    advisories = File.open(@msgpack_path) do |f|
      MessagePack::unpack(f)
    end
    advisories.values.map do |a|
      # One of the advisories, USN-208-1, has some invalid unicode that breaks things
      if !a["description"].valid_encoding?
        a["description"] = ActiveSupport::Multibyte::Unicode.tidy_bytes(a["description"].force_encoding("utf-8"))
      end
      a
    end
  end

  def parse(advisory)
    UsnAdapter.new(advisory,"")# advisory) 
  end

  def find_python
    @python ||= (`which python2` || `which python`).try(:chomp)
  end
end

