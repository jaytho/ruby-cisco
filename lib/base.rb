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
      options[:autoinit] ||= true
      @transport = Cisco.const_get(Cisco.constants.find {|const| const =~ Regexp.new(@transport.to_s, Regexp::IGNORECASE)}).new(options)
	  @info = OpenStruct.new
      extra_init("terminal length 0")
      refresh_info if options[:autoinit]
    end
    
    def refresh_info
    	info = run {|x| x.cmd("sh ver")}.last.split("\n")
    	info.each {|str| parse_and_assign(str)}
    end

	def host
		@transport.host
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


	private
	
	def parse_and_assign(str)
		case str
			when /^IOS|^CatOS/
				@info.os = str
			when /^Compiled\s/
				@info.compiled_at = str
			when /^ROM:\sBootstrap/
				@info.bootloader = str
			when /.*\suptime\sis\s/
				@info.uptime = str
			when /^System\sreturned/
				@info.returned_by = str
			when /^System\simage\sfile/
				@info.image = str
			when /processor/
				@info.processor = str
			when /Processor\sboard/
				@info.procboard = str
			when /^Last\sreset/
				@info.last_reset = str
			when /^\d+.*memory/
				@info.memory = str
			when /..:..:..:..:..:../
				@info.mac = str
			when /^Motherboard assembly number/
				@info.mobo_assembly_num = str
			when /^Power supply part number/
				@info.power_supply_part_num = str
			when /^Motherboard serial number/
				@info.mobo_serial_num = str
			when /^Power supply serial number/
				@info.power_supply_serial_num = str
			when /^Model revision number/
				@info.model_rev = str
			when /^Motherboard revision number/
				@info.mobo_rev = str
			when /^Model number/
				@info.model = str
			when /^System serial number/
				@info.serial = str
		end
	end

  end
  
end
