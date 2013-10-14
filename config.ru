require File.expand_path(File.dirname(__FILE__) + "/app/app")

stylesheets = Sprockets::Environment.new
stylesheets.append_path "app/assets/stylesheets"

javascripts = Sprockets::Environment.new
javascripts.append_path "app/assets/javascripts"

images = Sprockets::Environment.new
images.append_path "app/assets/images"

map("/css") { run stylesheets }
map("/js")  { run javascripts }
map("/img") { run images }
map("/")    { run Sinatra::Application }