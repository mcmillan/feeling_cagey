$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require "bundler"
require "pp"
Bundler.require
Dotenv.load

# Configuration
MongoMapper.setup({ 'development' => { 'uri' => ENV['MONGODB_URL'] } }, :development)
Instagram.configure do |config|
  config.client_id     = ENV["INSTAGRAM_CLIENT_ID"]
  config.client_secret = ENV["INSTAGRAM_CLIENT_SECRET"]
end

require "models/photo"