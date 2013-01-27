module Mac
  KEYCODES = {
    :esc => 53,
    :f1 => 122,
    :f2 => 120,
    :f3 => 99,
    :f4 => 118,
    :f5 => 96,
    :f6 => 97,
    :f7 => 98,
    :f8 => 100,
    :f9 => 101,
    :f10 => 109,
    :f11 => 103,
    :f12 => 111,
    :tab => 48,
    :delete => 51,
    :return => 36,
    :space => 49,
    :enter => 52,
    :left_arrow => 123,
    :right_arrow => 124,
    :down_arrow => 125,
    :up_arrow => 126
  }

  MODIFIERS = [:control, :command, :shift, :option]

  class << self
    def send_key(key, modifiers={})
      if KEYCODES.keys.include? key
        subcommand = "key code #{KEYCODES[key]}"
      else
        subcommand = "keystroke \"#{key}\""
      end

      supported_modifiers = MODIFIERS.map { |modifier| modifier if modifiers[modifier]==true }.compact
      supported_modifiers.map! {|modifier| "#{modifier} down"}
      modifier_string = "using {#{supported_modifiers.join(', ')}}" if supported_modifiers.length > 0

      command = "tell application \"System Events\" to #{subcommand} #{modifier_string}"

      run_apple_script [command]
    end

    def say(string,options={})
      voice = options[:voice] || 'Fred'
      rate = options[:rate] || 300
      rising_inflection = options[:rising_inflection] || true
      %x[say '#{string}#{rising_inflection ? '?' : ''}' -v #{voice} -r #{rate}]
    end

    def open_app(app_name)
      %x[open '/Applications/#{app_name}.app/']
    end

    def close_app(app_name)
      pre_condition = 'ignoring application responses'
      post_condition = 'end ignoring'

      command = "tell application \"#{app_name}\" to quit with saving"

      run_apple_script [pre_condition,command,post_condition]
    end

    private

    def run_apple_script(scripts)
      massaged_scripts = scripts.map {|script| "-e '#{script}'"}
      script_string = massaged_scripts.join(' ')

      %x[/usr/bin/osascript #{script_string} 2> /dev/null]
    end
  end
end
