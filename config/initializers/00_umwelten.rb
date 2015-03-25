settings_path = File.join(Rails.root, "config/settings", "**/*.yml")
Dir[settings_path].each do |file|
  new_conf = YAML.load_file(file)

  if new_conf[Rails.env]
    new_conf = new_conf[Rails.env]
  end

  key = new_conf.keys.first
  if key
    Rails.configuration.send("#{key}=", OpenStruct.new(new_conf[key]))
  end
end


require 'factory_girl'
require File.join(Rails.root, 'test/factories/user_factory')

