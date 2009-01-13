module Cisco

  class CiscoError < StandardError
  end

  class Base

    attr_reader :transport

    def initialize(options)
      @transport = options[:transport] || :telnet
      options[:prompt] ||= /[#>]\s?\z/n
      options[:password] ||= ""
      options[:autoinit] ||= true
      @transport = Cisco.const_get(Cisco.constants.find {|const| const =~ Regexp.new(@transport.to_s, Regexp::IGNORECASE)}).new(options)
      extra_init("terminal length 0")
    end

    def host
      @transport.host
    end
    
    def password
      @transport.password
    end
    
    def prompt
      @transport.prompt
    end

    def clear_cmd
      @transport.clear_cmd
    end

    def extra_init(*args)
      @transport.extra_init(*args)
    end

    def clear_init
      @transport.clear_init
    end

    def cmd(*args)
      @transport.cmd(*args)
    end

    def run(&block)
      @transport.run(&block)
    end

    def enable(*args)
      @transport.enable(*args)
    end

  end

end
