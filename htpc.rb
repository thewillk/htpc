require 'sinatra'
require 'haml'
require 'sass'

require './models/mac'

configure do
  set :haml, {:format => :html5}
  set :scss, {:style => :compact, :debug_info => false}
end

ALLOWED_APPS = ['Hulu Desktop', 'Plex', 'Sonos']

def process_app(id, &block)
  requested_app_name = id.split('_').map {|w| w.capitalize }.join(' ')
  if ALLOWED_APPS.include? requested_app_name
    yield(requested_app_name)
    200
  else
    403
  end
end

get '/' do
  @page_title = "Will's HTPC"
  haml :index
end

post '/open/:id' do
  process_app params[:id] do |app_name|
    Mac.open_app app_name
  end
end

post '/close/:id' do
  process_app params[:id] do |app_name|
    Mac.close_app app_name
  end
end

post '/type/:keys' do
  # should sanitize input; easy injection attack here
  Mac.send_key params[:keys]
end

post '/keypress/:key' do
  # should sanitize input; easy injection attack here
  Mac.send_key params[:key].to_sym
end

get '/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss(:"stylesheets/#{params[:name]}" )
end
