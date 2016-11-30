# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.2'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

Rails.application.config.assets.precompile += %w( application.css application.js launchrock.css launchrock.js greatreview.css isitvuln.js admin.js email.css )
Rails.application.config.assets.precompile += %w(*.svg *.eot *.woff *.woff2 *.ttf *.gif *.png *.ico)
# fontawesome-webfont.eot fontawesome-webfont.woff2 fontawesome-webfont.woff fontawesome-webfont.ttf fontawesome-webfont.svg
