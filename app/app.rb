require File.expand_path(File.dirname(__FILE__) + '/boot')

require "sinatra"
require "sinatra/reloader"

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