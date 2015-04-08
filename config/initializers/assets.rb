# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# let's ignore jsx and source map files, taken from
# the upstream assets.precompile code:

loose_assets = lambda do |logical_path, filename|
  filename.start_with?(::Rails.root.join("app/assets").to_s) &&
    !%w(.js .css .jsx .map).include?(File.extname(logical_path))
end

Rails.application.config.assets.precompile = [loose_assets]
Rails.application.config.assets.precompile += %w( application.css application.js launchrock.css launchrock.js )

# source maps!
if Rails.env.development?
  Rails.application.config.assets.configure do |env|
    env.unregister_postprocessor 'application/javascript', Sprockets::SafetyColons
  end
end

