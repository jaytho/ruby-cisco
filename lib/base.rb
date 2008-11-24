require 'ostruct'

module Cisco
    
  class CiscoError < StandardError
  end
  
  class Group < OpenStruct
    def to_a
      @table.values
    end
  end

  class Base
    
    attr_reader :info, :ints, :host, :transport
    
    def initialize(options)
      @transport = options[:transport] || :telnet
      options[:prompt] ||= /[#>]\s?\z/n
      options[:loginpw] ||= ""
      @transport = Cisco.const_get(@transport.to_s.capitalize)
      @transport = @transport.new(options)
    end
    
    def prompt=(prompt)
      @transport.prompt = prompt
    end
    
    def prompt
      @transport.prompt
    end
    
    def loginpw=(pw)
      @transport.loginpw = pw
    end
    
    def loginpw
      @transport.loginpw
    end
    
    # This is meant to be redefined in subclasses to send initial commands like 'terminal length 0' upon connecting.
    def extra_init(&block)
      @transport.extra_init(block)
    end
    
    def run(&block)
      @transport.run(&block)
    end
    
    # This closes the transport connection. This should be taken care of at the end of every run() block.
    def close
      @transport.close
    end

  end
  
end
