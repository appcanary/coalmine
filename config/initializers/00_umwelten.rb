require 'find'

settings_path = File.join(Rails.root, "config/settings")

search_dirs = [settings_path]
files = []

until search_dirs.empty?
  search_path = search_dirs.shift 
 
  Find.find(search_path) do |path|
  
    unless path == search_path 
    
      if File.directory?( path )
        puts "sd2 #{search_dirs}"
        search_dirs << path
      else
        files << path
      end

    end
  end
end


files.each do |file|
  new_conf = YAML.load_file(file)
  file_name = File.basename(file)
  next unless new_conf.is_a? Hash

  if new_conf[Rails.env]
    new_settings = new_conf[Rails.env]
  else
    new_settings = new_conf
  end

  key = new_settings.keys.first
  if key
    Rails.configuration.send("#{key}=", OpenStruct.new(new_settings[key]))
  end
end
