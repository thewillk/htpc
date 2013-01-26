# require 'upnp/ssdp'
require 'UPnP/SSDP'
require 'savon'

module WeMo
  TYPE = 'urn:Belkin:service:basicevent:1'
  class Device
    attr_reader :name

    def initialize(uri,expires_in=0)
      @endpoint = "#{uri.scheme}://#{uri.host}:#{uri.port}"
      @expires_in = expires_in
      @last_fetched = Time.now
      @name = get_name
    end

    def powered?
      response = send_soap 'GetBinaryState'
      get_powered_status_from_response_for_action response, :get_binary_state_response
    end

    def on!
      response = send_soap 'SetBinaryState', {:message => {'BinaryState' => "1"}}
      get_powered_status_from_response_for_action response, :set_binary_state_response
    end

    def off!
      response = send_soap 'SetBinaryState', {:message => {'BinaryState' => "0"}}
      get_powered_status_from_response_for_action response, :set_binary_state_response
    end

    def expired?
      (@expires_in > 0) && (Time.now > (@last_fetched + @expires_in))
    end

    private

    def get_name
      response = send_soap 'GetFriendlyName'
      response.to_array.first[:get_friendly_name_response][:friendly_name] if response.successful?
    end

    def get_powered_status_from_response_for_action(response,action)
      value = response.to_array.first[action][:binary_state] if response.successful?
      value == "1"
    end

    def send_soap(cmd,opts={})
      client_options = {
        :log => false,
        :namespace => TYPE,
        :endpoint => "#{@endpoint}/upnp/control/basicevent1",
        :headers => {"SOAPAction" => "\"#{TYPE}##{cmd}\""}
      }

      client = Savon.client client_options
      client.call cmd,opts
    end
  end

  class << self
    def initialize
      find_all_devices
    end

    def find_by_name(name)
      @devices = @devices || {}
      device = @devices[name]
      if device.nil? || device.expired?
        device = find_all_devices[name]
      end
      device
    end

    private

    def find_all_devices
      @devices = {}
      locations = []

      all_devices = UPnP::SSDP.new.search TYPE
      all_devices.each do |device_data|
        unless device_data.location.nil? || locations.include?(device_data.location.host)
          locations.push device_data.location.host
          device = Device.new(device_data.location, device_data.max_age)
          @devices[device.name] = device unless device.name.nil?
        end
      end

      @devices
    end
  end
end
