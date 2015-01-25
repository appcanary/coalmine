settings_path = File.join(Rails.root, "config/settings", "*")
Dir[settings_path].each do |file|
  new_conf = YAML.load_file(file)
  key = new_conf.keys.first
  if key
    Rails.configuration.send("#{key}=", OpenStruct.new(new_conf[key]))
  end
end
