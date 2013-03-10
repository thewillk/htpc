require 'net/telnet'

module Denon
  class << self
    ONE_TO_ONE_METHODS = {
      :on! => 'PWON',
      :off! => 'PWSTANDBY',
      :louder! => 'MVUP',
      :quieter! => 'MVDOWN',
      :mute! => 'MUON',
      :unmute! => 'MUOFF'
    }

    INPUT_NAMES = {
      :media_player => 'SIMPLAY',
      :bluray_player => 'SIBD',
      :phono => 'SIPHONO',
      :cd => 'SICD',
      :radio => 'SITUNER',
      :dvd => 'SIDVD',
      :hdp => 'SIHDP',
      :tv => 'SITV/CBL',
      :satelite => 'SISAT',
      :vcr => 'SIVCR',
      :dvr => 'SIDVR',
      :aux => 'SIV.AUX',
      :network_usb => 'SINET/USB',
      :xm => 'SIXM',
      :ipod => 'SIIPOD'
    }

    def powered?
      send_command('PW?') == 'PWON'
    end

    def muted?
      send_command('MU?') == 'MUON'
    end

    def selected_input?
      response = send_command('SI?')

      if INPUT_NAMES.invert.include? response
        INPUT_NAMES.invert[response]
      else
        response
      end
    end

    def set_volume! volume
      volume_at_string = "%02d" % volume
      raise 'Value must be between 00 and 99' if ("%02d" % (volume%100)) != volume_at_string
      send_command "MV#{volume_at_string}"
    end

    def method_missing(meth, *args, &block)
      if ONE_TO_ONE_METHODS.include? meth
        send_command ONE_TO_ONE_METHODS[meth] 
      elsif (meth.to_s =~ /^switch_to_(.+)!$/) and (INPUT_NAMES.include? $1.to_sym)
        send_command INPUT_NAMES[$1.to_sym]
      else
        super
      end
    end

    private

    def send_command(command)
      host = Net::Telnet::new(
          "Host"       => '192.168.4.111',  # need to make dynamic
          "Port"       => 23,
          "Binmode"    => false,
          "Prompt"     => /\Z/,
          "Telnetmode" => false,
          "Timeout"    => 10,
          "Waittime"   => 0
        )

      host.puts(command)

      response = ""
      host.waitfor(/\r/) do |server_text|
        response = server_text
        break
      end
      host.close

      response
    end
  end
end
