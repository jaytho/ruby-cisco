require 'net/telnet'

module Cisco

  class Telnet
    
    attr_accessor :loginpw
    attr_reader :host
    
    def initialize(options)
      @host    = options[:host]
		  @loginpw = options[:loginpw]
		  @prompt  = options[:prompt]
		  @targs   = options[:directargs] || ["Host" => @host]
    end

    def run(&block)
      @results, @cmdbuf = [], []
      @extra_init.call(self) if @extra_init
      block.call(self)
      @telnet = Net::Telnet.new(*@targs)
      login
      until @cmdbuf.empty?
        send_next
        @results << waitfor(@prompt) {|x| @outblock.call(x) if @outblock }
      end
      @telnet.close
      return @results
    end
  	
  	def cmd(cmd, prompt = nil, &block)
  		@cmdbuf << [cmd + "\n", prompt, block]
  	end
  	
  	def enable(password, pwprompt=nil)
  	  old = @prompt
      cmd("enable", pwprompt || "Password:")
      cmd(password, @prompt)
  	end

    def extra_init(&block)
		  @extra_init = block
		end
    
    private
    
    def login
      raise CiscoError.new("No login password provided.") unless @loginpw
      @results << waitfor(Regexp.new("Password:"))
      puts(@loginpw)
      @results << waitfor(@prompt)
    end
    
    def	send_next
  		cmd = @cmdbuf.shift
  		@prompt = Regexp.new(cmd[1]) if cmd[1]
  		@outblock = cmd[2] if cmd[2]
  		puts(cmd.first)
  	end

  end # class Telnet

end # module Cisco
