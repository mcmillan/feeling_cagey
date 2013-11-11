require File.expand_path(File.dirname(__FILE__) + '/boot')

require "sinatra"
require "sinatra/reloader"

set :server, :puma

get '/' do
  erb :index
end

get '/photos.json' do
  @photos = Photo.all_filtered_for_json

  content_type :json
  @photos.to_json
end