require "bundler"
Bundler.require
Dotenv.load

class Photo
  include MongoMapper::Document

  key :photo
  key :width
  key :height
  key :link
  key :author_username
  key :author_name
  key :author_picture
end

Instagram.configure do |config|
  config.client_id     = ENV["INSTAGRAM_CLIENT_ID"]
  config.client_secret = ENV["INSTAGRAM_CLIENT_SECRET"]
end

get '/callback' do
  return params['hub.challenge']
end

post '/callback' do
  Instagram.process_subscription(params[:body]) do |handler|
    handler.on_tag_changed do
      @media = Instagram.tag_recent_media(ENV['TAG'])
      puts @media.inspect
    end
  end
end