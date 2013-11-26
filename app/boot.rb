$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
ENV['RACK_ENV'] ||= 'development'

require "bundler"
require "pp"
Bundler.require
Dotenv.load

# Configuration
MongoMapper.setup({
  'production' => { 'uri' => ENV['MONGODB_URL'] }
}, 'production')

Instagram.configure do |config|
  config.client_id     = ENV["INSTAGRAM_CLIENT_ID"]
  config.client_secret = ENV["INSTAGRAM_CLIENT_SECRET"]
end

Pusher.url = ENV["PUSHER_URL"]

require "models/photo"
require "models/excluded_user"