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
    
    attr_reader :info, :ints, :transport
    
    def initialize(options)
      @transport = options[:transport] || :telnet
      options[:prompt] ||= /[#>]\s?\z/n
      options[:password] ||= ""
      @transport = Cisco.const_get(Cisco.constants.find {|const| const =~ Regexp.new(@transport.to_s, Regexp::IGNORECASE)}).new(options)
    end

	def host
		@transport.host
	end
	
	def extra_init(*args)
		@transport.extra_init(*args)
	end
	
	def cmd(*args)
		@transport.cmd(*args)
	end
	
	def run(&block)
		@transport.run(&block)
	end


  end
  
end
