settings_path = File.join(Rails.root, "config/settings", "**/**/*.yml")

Dir[settings_path].each do |file|
  new_conf = YAML.load_file(file)
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
