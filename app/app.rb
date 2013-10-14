require File.expand_path(File.dirname(__FILE__) + '/boot')

require "sinatra"
require "sinatra/reloader"

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

get '/' do
  erb :index
end

get '/photos.json' do
  @photos = []
  Photo.all.each do |photo|
    p = {
      filter: photo.filter_class,
      image_url: photo.image_url,
      faces: []
    }

    photo.faces.each do |face|
      p[:faces] << {
        top: top(face['top'], face['height'], photo.height),
        left: left(face['left'], face['width'], photo.width),
        width: width(face['width'], photo.width)
      }
    end

    @photos << p
  end

  content_type :json
  @photos.to_json
end