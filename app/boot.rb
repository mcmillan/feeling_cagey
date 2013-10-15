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
Pusher.url = ENV["PUSHER_URL"]

require "models/photo"

def top(face_top, face_height, photo_height)
  face_top -= (face_height * 0.1)

  biased_size(face_top, photo_height)
end

def left(face_left, face_width, photo_width)
  biased_face_width         = biased_size(face_width, photo_width)
  biased_resized_face_width = width(face_width, photo_width)

  skew = (biased_face_width - biased_resized_face_width) / 2
  
  biased_size(face_left, photo_width) + skew
end

def width(face_width, photo_width)
  face_width -= (face_width * 0.15)

  biased_size(face_width, photo_width)
end

def biased_size(face, photo)
  (320 * (face.to_f / photo.to_f)).to_i
end