require 'sinatra'
require 'haml'
require 'sass'
require 'pry'

require './models/mac'
require './models/wemo'

configure do
  set :haml, {:format => :html5}
  set :scss, {:style => :compact, :debug_info => false}
  @@wemo = WeMo
end

ALLOWED_APPS = ['Hulu Desktop', 'Plex', 'Sonos']
AVAILABLE_MODIFIERS = [:control, :command, :shift, :option]

def process_app(id, &block)
  requested_app_name = id.split('_').map {|w| w.capitalize }.join(' ')
  if ALLOWED_APPS.include? requested_app_name
    yield(requested_app_name)
    200
  else
    403
  end
end

def modifiers_from_params
  modifiers = {}
  AVAILABLE_MODIFIERS.each do |modifier|
    modifiers[modifier] = true if params[modifier]=='true'
  end
  modifiers
end

get '/wemo/:name/:action' do
  device = @@wemo.find_by_name params[:name]
  if params[:action]=='on'
    value = device.on! unless device.nil?
  elsif params[:action]=='off'
    value = device.off! unless device.nil?
  elsif params[:action]=='status'
    value = device.powered? unless device.nil?
  end
  value ? "ON" : "OFF"
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
  Mac.send_key params[:keys], modifiers_from_params
end

post '/keypress/:key' do
  # should sanitize input; easy injection attack here
  Mac.send_key params[:key].to_sym, modifiers_from_params
end

get '/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss(:"stylesheets/#{params[:name]}" )
end
