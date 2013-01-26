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

ALLOWED_WEMO_DEVICES = ['Subwoofer']

def name_from_url_friendly_id(id)
  id.split('_').map {|w| w.capitalize }.join(' ')
end

def process_app(id, &block)
  requested_app_name = name_from_url_friendly_id id
  if ALLOWED_APPS.include? requested_app_name
    yield(requested_app_name)
  else
    403
  end
end

def process_wemo(id, &block)
  requested_wemo_name = name_from_url_friendly_id id
  if ALLOWED_WEMO_DEVICES.include? requested_wemo_name
    yield(requested_wemo_name)
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

post '/wemo_switch/:id/:action' do
  process_wemo params[:id] do |name|
    if params[:action] == 'on'
      device = @@wemo.find_by_name name
      value = device.on! unless device.nil?
    elsif params[:action] == 'off'
      device = @@wemo.find_by_name name
      value = device.off! unless device.nil?
    else
      403
    end
  end
end

get '/wemo_switch/:id' do
  process_wemo params[:id] do |name|
    device = @@wemo.find_by_name name
    value = device.powered? unless device.nil?
    "{\"value\": #{value==true}}"
  end
end

get '/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss(:"stylesheets/#{params[:name]}" )
end
